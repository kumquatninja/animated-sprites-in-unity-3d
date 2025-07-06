// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "UI/AnimatedSpriteSheet"
{
    Properties
    {
        _MainTex ("Sprite Sheet", 2D) = "white" {}
        _Columns ("Columns", Float) = 4
        _Rows ("Rows", Float) = 4
        _Frame ("Frame", Float) = 0
        _OutlineSize ("OutlineSize", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Columns;
            float _Rows;
            float _Frame;
            float _OutlineSize;

            struct appdata_t            // Input from Unity mesh
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Vertex Shader
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            // Calculate the offset (which frame to display)
            float2 FrameToUVOffset(float frame, float columns, float rows)
            {
                float col = fmod(frame, columns);
                float row = floor(frame/columns);
                return float2(col / columns, 1.0 - (row + 1) / rows);
            }
            
            float2 AdjustedUV(float2 uv, float2 offset, float2 scale)
            {
                return uv * scale + offset;
            }

            fixed4 frag (v2f i) : SV_TARGET
            {
                float2 scale = float2(1.0 / _Columns, 1.0 / _Rows);
                float2 offset = FrameToUVOffset(_Frame, _Columns, _Rows);
                float2 uv = AdjustedUV(i.uv, offset, scale);

                // float outlineSize = 1.0/256.0;

                float alpha = tex2D(_MainTex, uv).a;
                float a1 = tex2D(_MainTex, uv + float2(_OutlineSize,  0)).a;
                float a2 = tex2D(_MainTex, uv + float2(-_OutlineSize,  0)).a;
                float a3 = tex2D(_MainTex, uv + float2(0,  _OutlineSize)).a;
                float a4 = tex2D(_MainTex, uv + float2(0, -_OutlineSize)).a;

                bool isOutline = alpha < 0.1 && (a1 > 0.1 || a2 > 0.1 || a3 > 0.1 || a4 > 0.1);

                if (isOutline)
                    return fixed4(1, 1, 1, 1); // White outline

                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
