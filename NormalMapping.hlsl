//───────────────────────────────────────
 // テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D		g_texture : register(t0);	//テクスチャー
SamplerState	g_sampler : register(s0);	//サンプラー
Texture2D		normalTex : register(t1);


//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer gmodel:register(b0)
{
	float4x4	matWVP;			// ワールド・ビュー・プロジェクションの合成行列
	float4x4	matW;           // ワールド行列
	float4x4	matNormal;           // ワールド行列
	float4		diffuseColor;		//マテリアルの色＝拡散反射係数
	float4      ambientColor;   //環境光
	float4      specularColor;  //鏡面反射＝ハイライト
	float       shininess;
	int         hasTexture;
	int         hasNormalMap;

};

cbuffer gmodel:register(b1)
{
	float4		lightPosition;
	float4		eyePosition;
};



//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
	float4 pos      :SV_POSITION;	//位置
	float2 uv	    :TEXCOORD;		//UV座標
	float4 eyev		:POSITION;
	float4 Neyev    :POSITION1;
	float4 normal	:POSITION2;
	float4 light    :POSITION3;
	float4 color    :POSITION4;
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL,float4 tangent:TANGENT)
{
	//ピクセルシェーダーへ渡す情報
	VS_OUT outData = (VS_OUT)0;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
	//スクリーン座標に変換し、ピクセルシェーダーへ
	outData.pos = mul(pos, matWVP);
	outData.uv = (float2)uv;

	float3  tmp = cross(tangent, normal);
	float4 binormal = { tmp, 0 };
	binormal = mul(binormal, matNormal);
	binormal = normalize(binormal); //従法線ベクトルをローカル座標に変換したやつ

	normal.w = 0;
	/*normal = mul(normal, matNormal);
	normal = normalize(normal);
	outData.normal = normal;*/
	outData.normal = normalize(mul(normal, matNormal));

	tangent = mul(tangent, matNormal);
	tangent.w = 0;
	tangent = normalize(tangent);

	binormal = mul(binormal, matNormal);
	binormal = normalize(tangent);

	float4 posw = mul(pos, matW);
	outData.eyev = normalize(posw - eyePosition);

	outData.light.x = dot(light, tangent);//接空間の光源ベクトル
	outData.light.y = dot(light, binormal);
	outData.light.z = dot(light, outData.normal);
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

	//まとめて出力
	return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
	float4 lightSource = float4(1.0, 1.0, 1.0, 1.0);
	float4 diffuse;
	float4 ambient;
	float4 specular;

	if (hasNormalMap)
	{
		/*diffuse = lightSource * diffuseColor * inData.color;
		ambient = lightSource * diffuseColor * ambentSource;*/
		float4 tmpNormal = normalTex.Sample(g_sampler, inData.uv) * 2.0f - 1.0f;
		tmpNormal = normalize(tmpNormal);
		tmpNormal.w = 0;
	
		float4 NL = clamp(dot(tmpNormal, inData.light), 0, 1);
		float4 reflection = reflect(-inData.light, tmpNormal);
		float4 specular = pow(saturate(dot(reflection, inData.Neyev)), shininess) * specularColor;

		if(hasTexture != 0)
		{
			diffuse = lightSource * g_texture.Sample(g_sampler, inData.uv) * NL;
			ambient = lightSource * g_texture.Sample(g_sampler, inData.uv) * ambientColor;
		}
		else
		{
			diffuse = lightSource * diffuseColor * NL;
			ambient = lightSource * diffuseColor * ambientColor;
		}
		return   diffuse + ambient + specular;

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
		return diffuse + ambient + specular;
	}
}

	//return g_texture.Sample(g_sampler, inData.uv);

