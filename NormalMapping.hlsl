//������������������������������������������������������������������������������
 // �e�N�X�`�����T���v���[�f�[�^�̃O���[�o���ϐ���`
//������������������������������������������������������������������������������
Texture2D		g_texture : register(t0);	//�e�N�X�`���[
SamplerState	g_sampler : register(s0);	//�T���v���[
Texture2D		normalTex : register(t1);


//������������������������������������������������������������������������������
// �R���X�^���g�o�b�t�@
// DirectX �����瑗�M����Ă���A�|���S�����_�ȊO�̏����̒�`
//������������������������������������������������������������������������������
cbuffer gmodel:register(b0)
{
	float4x4	matWVP;			// ���[���h�E�r���[�E�v���W�F�N�V�����̍����s��
	float4x4	matW;           // ���[���h�s��
	float4x4	matNormal;           // ���[���h�s��
	float4		diffuseColor;		//�}�e���A���̐F���g�U���ˌW��
	float4      ambientColor;   //����
	float4      specularColor;  //���ʔ��ˁ��n�C���C�g
	float       shininess;
	int         hasTexture;
	int         hasNormalMap;

};

cbuffer gmodel:register(b1)
{
	float4		lightPosition;
	float4		eyePosition;
};



//������������������������������������������������������������������������������
// ���_�V�F�[�_�[�o�́��s�N�Z���V�F�[�_�[���̓f�[�^�\����
//������������������������������������������������������������������������������
struct VS_OUT
{
	float4 pos  : SV_POSITION;	//�ʒu
	float2 uv	: TEXCOORD;		//UV���W
	float4 eyev		:POSITION;
	float4 Neyev    :POSITION1;
	float4 normal	:POSITION2;
	float4 light    :POSITION3;
	float4 color    :POSITION4;
};

//������������������������������������������������������������������������������
// ���_�V�F�[�_
//������������������������������������������������������������������������������
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL,float4 tangent:TANGENT)
{
	//�s�N�Z���V�F�[�_�[�֓n�����
	VS_OUT outData = (VS_OUT)0;

	//���[�J�����W�ɁA���[���h�E�r���[�E�v���W�F�N�V�����s���������
	//�X�N���[�����W�ɕϊ����A�s�N�Z���V�F�[�_�[��
	outData.pos = mul(pos, matWVP);
	outData.uv = (float2)uv;

	float3 binormal = cross(normal, tangent);

	normal.w = 0;
	normal = mul(normal, matNormal);
	normal = normalize(normal);
	outData.normal = normal;

	tangent.w = 0;
	tangent = mul(tangent, matNormal);
	tangent = normalize(tangent);

	binormal = mul(binormal, matNormal);
	binormal = normalize(tangent);

	float4 posw = mul(pos, matW);
	outData.eyev = normalize(posw - eyePosition);

	outData.Neyev.x = dot(outData.eyev, tangent);//�ڋ�Ԃ̎����x�N�g��
	outData.Neyev.y = dot(outData.eyev, binormal);
	outData.Neyev.z = dot(outData.eyev, normal);
	outData.Neyev.w = 0;

	float4 light = normalize(lightPosition);
	light.w = 0;
	light = normalize(light);

	outData.color = mul(light, normal);
	outData.color.w = 0.0;

	outData.light.x = dot(light, tangent);
	outData.light.y = dot(light, binormal);
	outData.light.z = dot(light, normal);
	outData.light.w = 0;

	//�܂Ƃ߂ďo��
	return outData;
}

//������������������������������������������������������������������������������
// �s�N�Z���V�F�[�_
//������������������������������������������������������������������������������
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
	float4 diffuse;
	float4 ambient;

	if (hasNormalMap)
	{
		/*diffuse = lightSource * diffuseColor * inData.color;
		ambient = lightSource * diffuseColor * ambentSource;*/
		float4 tmpNormal = normalTex.Sample(g_sampler, inData.uv) * 2.0f - 1.0f;
		tmpNormal.w = 0;
		tmpNormal = normalize(tmpNormal);
	
		float4 NL = clamp(dot(tmpNormal, inData.light), 0, 1);


		float4 reflection = reflect(-inData.light, tmpNormal);
		float4 specular=pow(saturate(dot(reflection, inData.Neyev)), shininess) * specularColor

		if(hasTexture != 0)
		{
			diffuse = g_texture.Sample(g_sampler, inData.uv) * NL;
			ambient = g_texture.Sample(g_sampler, inData.uv) * ambientColor;
		}
		else
		{
			diffuse = diffuseColor * NL;
			ambient = diffuseColor * ambientColor;
		}
		return   specular;

	}
	else
	{
		float4 reflection = reflect(normalize(lightPosition), inData.normal);

		float4 specular = pow(saturate(dot(normalize(reflection), inData.eyev)), shininess) * specularColor;
		if (hasTexture == 0)
		{
			diffuse = lightSource * diffuseColor * inData.color;
			ambient = lightSource * diffuseColor * ambientColor;
		}
		else
		{
			diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * inData.color;
			ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * ambientColor;
		}
		return specular;
	}
}

	//return g_texture.Sample(g_sampler, inData.uv);
}