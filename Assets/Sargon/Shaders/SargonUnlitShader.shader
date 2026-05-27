Shader "Custom/SilhouetteOutline"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _OutlineColor("Outline Color", Color) = (0,0,0,1)
        _OutlineThickness("Outline Thickness", Float) = 0.03
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalRenderPipeline" }

        // =========================
        // OUTLINE PASS
        // =========================
        Pass
        {
            Name "Outline"

            Cull Front
            ZWrite On
//            ZTest Always

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
            };

            half4 _OutlineColor;
            float _OutlineThickness;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                float3 posOS = IN.positionOS.xyz;
                float3 normalOS = IN.normalOS;

                // simple object-space expansion
                posOS += normalOS * _OutlineThickness;

                OUT.positionHCS = TransformObjectToHClip(posOS);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return _OutlineColor;
            }

            ENDHLSL
        }

        // =========================
        // MAIN PASS
        // =========================
        Pass
        {
            Name "Main"
            Tags { "LightMode"="UniversalForward" }
            
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            half4 _BaseColor;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                return _BaseColor;
            }

            ENDHLSL
        }
    }
}