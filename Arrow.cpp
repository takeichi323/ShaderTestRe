#include "Arrow.h"
#include "Engine/Model.h"
#include "Engine/Fbx.h"

//コンストラクタ
Arrow::Arrow(GameObject* parent)
    :GameObject(parent, "Arrow"), hArrow_(-1)
{
}

//デストラクタ
Arrow::~Arrow()
{
}

//初期化
void Arrow::Initialize()
{
    //モデルデータのロード
    hArrow_ = Model::Load("assets/Arrow.fbx");
    assert(hArrow_ >= 0);
}

//更新
void Arrow::Update()
{
}

//描画
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

//開放
void Arrow::Release()
{
}
