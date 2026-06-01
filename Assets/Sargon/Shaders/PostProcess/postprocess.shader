Shader "Custom/postprocess"
{   
    SubShader
    {
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
        ENDHLSL

        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite Off Cull Off
        Pass
        {
            Name "postprocess"

            HLSLPROGRAM
            
            #pragma vertex Vert
            #pragma fragment Frag
            
            float _FireIntensity;
            
            float4 Frag (Varyings input) : SV_Target
            {
                float2 uv = input.texcoord;

                float noise =
                    SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv).r;

                float distortionStrength = _FireIntensity * 0.02;

                uv += (noise - 0.5) * distortionStrength;

                float4 color =
                    SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);

                return color;
            }
            
            ENDHLSL
        }
    }
}
