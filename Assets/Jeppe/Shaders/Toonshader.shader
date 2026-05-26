Shader "Custom/ToonShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Threshold ("Threshold", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
            };

            float4 _Color;
            float _Threshold;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
{
    float3 lightDir = normalize(_MainLightPosition.xyz);

    float NdotL = dot(normalize(IN.normalWS), lightDir);

    float light = step(_Threshold, NdotL);

    float3 baseColor = float3(1, 0.8, 0.5); // varm Borderlands farve
    float3 shadowColor = float3(0.2, 0.15, 0.1);

    float3 color = lerp(shadowColor, baseColor, light);

    return float4(color, 1);
}

            ENDHLSL
        }
    }
}