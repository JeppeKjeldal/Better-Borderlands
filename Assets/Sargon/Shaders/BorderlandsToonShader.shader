// Definerer shaderens navn og hvor den findes i Unitys materiale-menu (Custom -> BorderlandsToonShader)
Shader "Custom/BorderlandsToonShader"
{
    // Properties-blokken indeholder de variabler, som du kan justere direkte i Unitys Inspector
    Properties
    {
        // Toon properties (Selve farven og teksturen på objektet)
        _MainTex ("Texture", 2D) = "white" {}            // Hovedteksturen. Standard er hvid, hvis ingen vælges
        _Tint ("Tint Color", Color) = (1,1,1,1)          // En farve der tones henover teksturen (Standard: Hvid/Ingen ændring)
        _ShadowTint ("Shadow Tint", Color) = (0.3,0.3,0.3,1) // Hvor mørk skyggen skal være (Standard: Mørkegrå)
        _Threshold ("Light Threshold", Range(0,1)) = 0.5 // Grænsen for, hvornår lyset skifter hårdt over i skygge

        // Outline properties (Kanten rundt om objektet)
        _OutlineColor ("Outline Color", Color) = (0,0,0,1) // Farven på outlinen (Standard: Sort)
        _OutlineThickness ("Thickness", Float) = 0.03    // Hvor tyk outlinen skal være
    }

    // SubShader indeholder den egentlige kode, der kører på grafikkortet
    SubShader
    {
        // Tags fortæller Unity, at dette objekt er uigennemsigtigt (Opaque), og at det SKAL bruge URP (UniversalPipeline)
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }

        // ==========================================
        // --- PASS 1: OUTLINE (Inverted Hull metoden)
        // ==========================================
        Pass
        {
            Name "Outline" // Giver dette specifikke pass et navn til organisering
            
            // Fortæller URP, at dette er et ekstra, unlit (uden standard lysberegning) pass
            Tags { "LightMode" = "SRPDefaultUnlit" } 
            
            // Sørger for, at vi kun tegner FORSIDERNE væk, dvs. vi tegner KUN bagsiden af 3D-modellen
            Cull Front

            HLSLPROGRAM // Starten på HLSL-koden (High-Level Shading Language)
            
            // Definerer hvad vertex- og fragment-funktionerne hedder i dette pass
            #pragma vertex vertOutline
            #pragma fragment fragOutline

            // Inkluderer URP's standard bibliotek med vigtige matematiske funktioner og transformationer
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Data der kommer ind fra 3D-modellens mesh (Object Space)
            struct AttributesOutline
            {
                float4 positionOS : POSITION; // Vertexens position i lokal-koordinater (Object Space)
                float3 normalOS : NORMAL;     // Retningen som vertexen peger (Normalen) i lokal-koordinater
            };

            // Data der sendes videre fra Vertex- til Fragment-shaderen
            struct VaryingsOutline
            {
                float4 positionHCS : SV_POSITION; // Vertexens endelige position på skærmen (Homogeneous Clip Space)
            };

            // Forbinder C#-variablerne fra Properties-blokken, så HLSL kan bruge dem
            float _OutlineThickness;
            float4 _OutlineColor;

            // Vertex-shaderen: Manipulerer formen på 3D-modellen
            VaryingsOutline vertOutline(AttributesOutline IN)
            {
                VaryingsOutline OUT;
                
                // Gør modellen en lille smule større ved at skubbe vertexerne udad i retningen af deres normaler
                float3 pos = IN.positionOS.xyz + IN.normalOS * _OutlineThickness;
                
                // Transformer den oppustede model fra lokal-koordinater til skærm-koordinater (Clip Space)
                OUT.positionHCS = TransformObjectToHClip(pos);
                
                return OUT; // Sender resultatet videre til fragment-shaderen
            }

            // Fragment-shaderen: Bestemmer farven på hver enkelt pixel på outlinen
            half4 fragOutline(VaryingsOutline IN) : SV_Target
            {
                // Returnerer bare den ensartede farve, du har valgt i Inspectoren (f.eks. sort)
                return _OutlineColor;
            }
            ENDHLSL // Slut på HLSL-koden for dette pass
        }

        // ==========================================
        // --- PASS 2: TOON SHADING (Selve objektet)
        // ==========================================
        Pass
        {
            Name "Toon" // Navnet på dette pass
            
            // Fortæller URP, at dette er shaderens hoved-pass, som skal modtage lys og skygger
            Tags { "LightMode" = "UniversalForward" } 
            
            // Sørger for, at vi kun tegner forsiden af modellen (normal 3D-rendering)
            Cull Back

            HLSLPROGRAM // Starten på HLSL-koden for Toon-shadingen
            
            // Definerer vertex- og fragment-funktionerne for dette pass
            #pragma vertex vertToon
            #pragma fragment fragToon

            // Inkluderer URP biblioteket igen
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // URP-specifik måde at definere en 2D-tekstur og dens tilhørende sampler (filter/gentagelses-indstillinger)
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // Data der kommer ind fra 3D-modellens mesh til Toon-shadingen
            struct AttributesToon
            {
                float4 positionOS : POSITION; // Vertexens position i lokal-koordinater
                float3 normalOS : NORMAL;     // Normalen i lokal-koordinater
                float2 uv : TEXCOORD0;        // UV-koordinaterne (hvordan teksturen skal placeres på modellen)
            };

            // Data der sendes fra Vertex- til Fragment-shaderen i Toon-shadingen
            struct VaryingsToon
            {
                float4 positionHCS : SV_POSITION; // Positionen på skærmen (Skal altid bruges)
                float3 normalWS : TEXCOORD0;      // Normalen transformeret til Verdens-koordinater (World Space)
                float2 uv : TEXCOORD1;            // UV-koordinaterne sendes med videre til pixelniveau
            };

            // Forbinder properties fra Inspectoren til HLSL-koden
            float4 _Tint;
            float4 _ShadowTint;
            float _Threshold;

            // Vertex-shaderen: Forbereder dataet til rendering
            VaryingsToon vertToon(AttributesToon IN)
            {
                VaryingsToon OUT;
                
                // Transformer vertex-positionen direkte til skærmen (uden at puste den op denne gang!)
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                // Transformer normalen fra lokal-koordinater til verdens-koordinater (Vigtigt for lysberegning)
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                
                // Giver UV-koordinaterne uændret videre
                OUT.uv = IN.uv;
                
                return OUT;
            }

            // Fragment-shaderen: Beregner lys, skygge og farve for hver pixel
            half4 fragToon(VaryingsToon IN) : SV_Target
            {
                // Finder retningen på scenens hovedlys (typisk din Directional Light) via en indbygget URP-variabel
                float3 lightDir = normalize(_MainLightPosition.xyz);

                // Matematisk "Dot Product" (prikprodukt) mellem overfladens retning (normal) og lysets retning.
                // Giver en værdi mellem -1 (helt væk fra lyset) og 1 (direkte mod lyset).
                float NdotL = dot(normalize(IN.normalWS), lightDir);

                // Cel-shading magien: step() returnerer 0, hvis NdotL er mindre end _Threshold, og 1 hvis den er større.
                // Det fjerner de bløde skygger og laver en fuldstændig hård, tegneserieagtig overgang.
                float light = step(_Threshold, NdotL);

                // Sætter teksturen på objektet ved hjælp af UV-koordinaterne
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);

                // Beregner grundfarven (Tekstur * Farve-toning)
                float3 baseColor = tex.rgb * _Tint.rgb;
                
                // Beregner skyggefarven (Grundfarven ganget med skygge-toningen)
                float3 shadowColor = baseColor * _ShadowTint.rgb;

                // Vælger enten skygge eller grundfarve alt efter om 'light' er 0 (skygge) eller 1 (lys)
                float3 finalColor = lerp(shadowColor, baseColor, light);

                // Returnerer den endelige farve på pixlen (med en Alpha/gennemsigtighed på 1, dvs. helt synlig)
                return float4(finalColor, 1);
            }
            ENDHLSL // Slut på HLSL-kode
        }
    }
}