Shader "Custom/SargonFire"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}

        _FireNoise("Fire Noise", 2D) = "white" {}
        _FireColor("Fire Color", Color) = (1,0.4,0,1)

        _FireSpeed("Fire Scroll Speed", Float) = 1.0
        _FireThreshold("Fire Threshold", Range(0,1)) = 0.6
        _EmissionStrength("Emission Strength", Float) = 3.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }

        Pass
        {
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

            TEXTURE2D(_FireNoise);
            SAMPLER(sampler_FireNoise);

            CBUFFER_START(UnityPerMaterial)

                half4 _BaseColor;
                float4 _BaseMap_ST;

                half4 _FireColor;

                float _FireSpeed;
                float _FireThreshold;
                float _EmissionStrength;

            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Base texture
                half4 baseColor =
                    SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv)
                    * _BaseColor;
                
                float heightMask = IN.uv.y;

                // Scrolling fire UVs
                float2 fireUV = IN.uv;

                // fireUV.y += _Time.y * _FireSpeed; //Down
                fireUV.y -= _Time.y * _FireSpeed; //Up

                // Sample noise texture
                float fireNoise =
                    SAMPLE_TEXTURE2D(_FireNoise, sampler_FireNoise, fireUV).r;

                // Create fire mask
                float fireMask =
                    smoothstep(
                        _FireThreshold,
                        _FireThreshold + 0.1,
                        fireNoise
                    );
                fireMask *= heightMask;

                // Fire emission
                half3 fireEmission =
                    fireMask
                    * fireNoise
                    * _FireColor.rgb
                    * _EmissionStrength;

                // Final color
                half3 finalColor =
                    baseColor.rgb + fireEmission;

                return half4(finalColor, baseColor.a);
            }

            ENDHLSL
        }
    }
}