Shader "Unlit/GradientShader"
{
    Properties
    {
        _RampTex ("RampTxt", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1 ,1 ,1 ,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8,255)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float  _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RampTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,o.vertex).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = 0.5 *dot(worldNormal,worldLight) + 0.5;

                fixed3 diffuse = _Diffuse.rgb * tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _LightColor0.rgb;

                fixed3 halfDir = normalize(worldLight + worldView);
                fixed3 specular = _LightColor0.rgb *  _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
               
                return fixed4(ambient + diffuse + specular,1.0f);
            }
            ENDCG
        }
    }
}
