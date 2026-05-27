Shader "Custom/SargonFireBillboard"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
        
        _FireScrollSpeed("Fire Scroll Speed", Float) = 1.0
        _FadeStart("Fade Start", Range(0,1)) = 0.6
        _FadeEnd("Fade End", Range(0,1)) = 1.0
        _EdgeFadeStart("Edge Fade Start", Range(0,1)) = 0.6
        _EdgeFadeEnd("Edge Fade End", Range(0,1)) = 1.0
        _Brightness("Brightness", Float) = 2.0
        _EdgeNoiseStrength("Edge Noise Strength", Range(0,1)) = 0.2
        _AlphaNoiseStrength("Alpha Noise Strength", Range(0,1)) = 0.15
        _BillboardScale("Billboard Scale", Float) = 1.0 //Use this to scale the flames
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off
            
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                float _FireScrollSpeed;
                float _FadeStart;
                float _FadeEnd;
                float _EdgeFadeStart;
                float _EdgeFadeEnd;
                float _Brightness;
                float _EdgeNoiseStrength;
                float _AlphaNoiseStrength;
                float _BillboardScale;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 worldPos = TransformObjectToWorld(float3(0,0,0));

                float3 cameraPos = GetCameraPositionWS();

                float3 forward = normalize(cameraPos - worldPos);

                float3 right = normalize(cross(float3(0,1,0), forward));
                float3 up = cross(forward, right);
                
                float3 local = IN.positionOS.xyz * _BillboardScale;

                float3 billboard =
                    worldPos +
                    (right * local.x + up * local.y);

                OUT.positionHCS = TransformWorldToHClip(billboard);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 fireUV = IN.uv;
                float edgeX = abs(IN.uv.x - 0.5) * 2.0;

                fireUV.y -= _Time.y * _FireScrollSpeed;

                half4 color =
                    SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, fireUV)
                    * _BaseColor;
                
                float noise = color.r; //Sample

                float noisyHeight =
                   IN.uv.y - (noise * _AlphaNoiseStrength);

                float alphaFade =
                    1.0 - smoothstep(
                        _FadeStart,
                        _FadeEnd,
                        noisyHeight
                    );

                color.a *= alphaFade;
                
                
                float noisyEdge =
                edgeX - (noise * _EdgeNoiseStrength);

                float edgeFade =
                    1.0 - smoothstep(
                        _EdgeFadeStart,
                        _EdgeFadeEnd,
                        noisyEdge
                    );
                
                color.a *= edgeFade;
                color.rgb *= _Brightness;

                return color;
            }
            ENDHLSL
        }
    }
}
