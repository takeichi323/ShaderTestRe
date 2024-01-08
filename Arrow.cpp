#include "Arrow.h"
#include "Engine/Model.h"
#include "Engine/Fbx.h"

//�R���X�g���N�^
Arrow::Arrow(GameObject* parent)
    :GameObject(parent, "Arrow"), hArrow_(-1)
{
}

//�f�X�g���N�^
Arrow::~Arrow()
{
}

//������
void Arrow::Initialize()
{
    //���f���f�[�^�̃��[�h
    hArrow_ = Model::Load("assets/Arrow.fbx");
    assert(hArrow_ >= 0);
}

//�X�V
void Arrow::Update()
{
}

//�`��
void Arrow::Draw()
{
    Transform xt, yt, zt;
    xt.rotate_.y = 0;
    xt.scale_ = { 0.5, 0.5, 0.5 };
    yt.rotate_.z = 90;
    yt.scale_ = { 0.5, 0.5, 0.5 };
    zt.rotate_.y = -90;
    zt.scale_ = { 0.5, 0.5, 0.5 };
    Model::SetTransform(hArrow_, xt);
    Model::Draw(hArrow_);
    Model::SetTransform(hArrow_, yt);
    Model::Draw(hArrow_);
    Model::SetTransform(hArrow_, zt);
    Model::Draw(hArrow_);
}

//�J��
void Arrow::Release()
{
}
