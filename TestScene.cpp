#include "TestScene.h"
#include "Engine/Input.h"
#include "Engine/SceneManager.h"
#include "Stage.h"
#include "Engine/Camera.h"

TestScene::TestScene(GameObject* parent)
	:GameObject(parent, "TenstScene")
{
}

void TestScene::Initialize()
{
	Instantiate<Stage>(this);
}

void TestScene::Update()
{
}

void TestScene::Draw()
{
}

void TestScene::Release()
{
}
