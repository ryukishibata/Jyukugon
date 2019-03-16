// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/UIPortal"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }        
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            sampler2D _SubTex;//★PortalControllerで追加
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float2 _Position;//★左下を原点とした時のマウスの位置(0〜1)
            float _Aspect;//★height/width(177928)
            float _Radius;//★円の半径
            float _DistortionWidth;//★縁の歪み幅

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                OUT.color = v.color * _Color;
                return OUT;
            }

            fixed4 frag(v2f IN, v2f_img i) : SV_Target
            {              
                // ◆自身のピクセルからポータル中心までの距離
                //  (ポータル中心と走査中の任意のピクセルまでの距離) * アスペクト比
                //  lengthで距離の絶対値が返る？
                float dist = length((_Position - i.uv) * float2(1, _Aspect));
                
                // ◆自身のピクセル位置での歪み具合
                //  smoothstep(a, b, x)：xが(a〜b)の間ならば(0〜1)を、それ以外はxを返す
                //  distortion:(1:穴部分, 1>0:圧縮画像, 0:メイン画)
                float distortion = 1 - smoothstep(_Radius - _DistortionWidth, _Radius, dist);
                
                
                // ◆自身のピクセル位置での歪み具合分だけ
                //  ポータル中心の方へずらしたuvを計算します
                fixed2 uv = i.uv + (_Position - i.uv) * distortion;                            
                
                // ◆計算したuvで出力テクスチャを切り替える
                // lerp(a,b,x):(x=0)=>(a=1,b=0),(x=1)=>(a=0,b=1)で表示する
                // step(a, x)  :(x>=a) ? 1 : 0;
                // １以上：サブ画像, １未満：メイン画像
                return lerp(tex2D(_MainTex,uv),
                            tex2D(_SubTex, i.uv),
                            step(1, distortion));
            }
        ENDCG
        }
    }
}
