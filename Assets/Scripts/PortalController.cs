using DG.Tweening;
using UnityEngine;

public class PortalController : MonoBehaviour {

    [SerializeField]
    Material material;//UIPortalshader付きのマテリアル
    [SerializeField]
    Texture texture;//合成したいテクスチャがある場合はセットする
    [SerializeField]
    float radius = 0.15f;
    [SerializeField]
    float distortionWidth = 0.07f;

    /*===========================================================*
     * ◆Start
     *===========================================================*/
    void Start()
    {
        material.SetTexture("_SubTex", texture);
    }
    /*===========================================================*
     * ◆Update
     *===========================================================*/
    void Update()
    {
        /*---------------------------------------- タップ位置を渡す */
        var mousePosition = Input.mousePosition;

        var uv = new Vector3(
            mousePosition.x / Screen.width,
            mousePosition.y / Screen.height, 0);

        material.SetVector("_Position", uv);
        material.SetFloat("_Aspect", Screen.height / (float)Screen.width);

        /*---------------------------------------- マウスクリック時 */
        if (Input.GetMouseButtonDown(0))
        {
            OpenPortal();
        }
        else if (Input.GetMouseButtonUp(0))
        {
            ClosePortal();
        }
    }

    /*-----------------------------------------------------------*
     * ◆円のアニメーション関数群
     *-----------------------------------------------------------*/
    float currentPortalRadius = 0;
    void OpenPortal()
    {
        DOTween.KillAll();
        //DOTween.To(() => 何を対象にするのか,値の更新,最終的な値,アニメーション時間);
        DOTween.To(() => currentPortalRadius, SetPortalRadius, radius, 2f).SetEase(Ease.OutBack);
    }

    void ClosePortal()
    {
        DOTween.KillAll();
        DOTween.To(() => currentPortalRadius, SetPortalRadius, 0f, 0.6f).SetEase(Ease.InBack);
    }

    void SetPortalRadius(float _radius)
    {
        currentPortalRadius = _radius;
        material.SetFloat("_Radius", _radius);
        material.SetFloat("_DistortionWidth", distortionWidth);
    }
    /*-----------------------------------------------------------*
     * ◆OnRenderImag
     *　・カメラの映像にポストエフェクトをつける際に使用する
     *　・すべてのレンダリングがRenderImageへと完了したときに呼び出される
     *-----------------------------------------------------------*/
    //void OnRenderImage(RenderTexture src, RenderTexture dest)
    //{
    //    Graphics.Blit(src, dest, material);
    //}
}
