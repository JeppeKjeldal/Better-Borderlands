Shader "Custom/BorderlandsToonFire"
{
    Properties
    {
        // Toon
        _MainTex ("Texture", 2D) = "white" {}
        _Tint ("Tint Color", Color) = (1,1,1,1)
        _ShadowTint ("Shadow Tint", Color) = (0.3,0.3,0.3,1)
        _Threshold ("Light Threshold", Range(0,1)) = 0.5

        // Outline
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineThickness ("Thickness", Float) = 0.03

        // Fire
        _FireNoise("Fire Noise", 2D) = "white" {}
        _FireColor("Fire Color", Color) = (1,0.4,0,1)

        _FireSpeed("Fire Scroll Speed", Float) = 1.0
        _FireThreshold("Fire Threshold", Range(0,1)) = 0.6
        _EmissionStrength("Emission Strength", Float) = 3.0

        [Toggle] _FlamesEnabled("Flames Enabled", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }

        // ==========================================
        // OUTLINE PASS
        // ==========================================
        Pass
        {
            Name "Outline"

            Tags
            {
                "LightMode" = "SRPDefaultUnlit"
            }

            Cull Front

            HLSLPROGRAM

            #pragma vertex vertOutline
            #pragma fragment fragOutline

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct AttributesOutline
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct VaryingsOutline
            {
                float4 positionHCS : SV_POSITION;
            };

            float _OutlineThickness;
            float4 _OutlineColor;

            VaryingsOutline vertOutline(AttributesOutline IN)
            {
                VaryingsOutline OUT;

                float3 pos =
                    IN.positionOS.xyz +
                    IN.normalOS * _OutlineThickness;

                OUT.positionHCS =
                    TransformObjectToHClip(pos);

                return OUT;
            }

            half4 fragOutline(VaryingsOutline IN) : SV_Target
            {
                return _OutlineColor;
            }

            ENDHLSL
        }

        // ==========================================
        // TOON + FIRE PASS
        // ==========================================
        Pass
        {
            Name "Toon"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull Back

            HLSLPROGRAM

            #pragma vertex vertToon
            #pragma fragment fragToon

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_FireNoise);
            SAMPLER(sampler_FireNoise);

            struct AttributesToon
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct VaryingsToon
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)

                float4 _Tint;
                float4 _ShadowTint;
                float _Threshold;

                float4 _FireColor;

                float _FireSpeed;
                float _FireThreshold;
                float _EmissionStrength;
                float _FlamesEnabled;

            CBUFFER_END

            VaryingsToon vertToon(AttributesToon IN)
            {
                VaryingsToon OUT;

                OUT.positionHCS =
                    TransformObjectToHClip(IN.positionOS.xyz);

                OUT.normalWS =
                    TransformObjectToWorldNormal(IN.normalOS);

                OUT.uv = IN.uv;

                return OUT;
            }

            half4 fragToon(VaryingsToon IN) : SV_Target
            {
                // ============================
                // TOON SHADING
                // ============================

                float3 lightDir =
                    normalize(_MainLightPosition.xyz);

                float NdotL =
                    dot(normalize(IN.normalWS), lightDir);

                float light =
                    step(_Threshold, NdotL);

                float4 tex =
                    SAMPLE_TEXTURE2D(
                        _MainTex,
                        sampler_MainTex,
                        IN.uv
                    );

                float3 baseColor =
                    tex.rgb * _Tint.rgb;

                float3 shadowColor =
                    baseColor * _ShadowTint.rgb;

                float3 toonColor =
                    lerp(
                        shadowColor,
                        baseColor,
                        light
                    );

                // ============================
                // FIRE OVERLAY
                // ============================

                float heightMask = IN.uv.y;

                float2 fireUV = IN.uv;
                fireUV.y -= _Time.y * _FireSpeed;

                float fireNoise =
                    SAMPLE_TEXTURE2D(
                        _FireNoise,
                        sampler_FireNoise,
                        fireUV
                    ).r;

                float fireMask =
                    smoothstep(
                        _FireThreshold,
                        _FireThreshold + 0.1,
                        fireNoise
                    );

                fireMask *= heightMask;

                float3 fireEmission =
                    fireMask
                    * fireNoise
                    * _FireColor.rgb
                    * _EmissionStrength
                    * _FlamesEnabled;

                // ============================
                // FINAL
                // ============================

                float3 finalColor =
                    toonColor +
                    fireEmission;

                return float4(finalColor, 1);
            }

            ENDHLSL
        }
    }
}