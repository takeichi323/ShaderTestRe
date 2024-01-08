#pragma once
#include "Engine/GameObject.h"
#include "Engine/Fbx.h"

//���������Ǘ�����N���X
class Arrow : public GameObject
{
    Fbx* pFbx;
    int hArrow_;
public:
    //�R���X�g���N�^
    Arrow(GameObject* parent);

    //�f�X�g���N�^
    ~Arrow();

    //������
    void Initialize() override;

    //�X�V
    void Update() override;

    //�`��
    void Draw() override;

    //�J��
    void Release() override;
};

