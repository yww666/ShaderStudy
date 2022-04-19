Shader "Unlit/WorldSpaceNormalMapShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse",Color) = (1,1,1,1)
        _Specular ("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss",range(8,256)) = 30
        _NormalMap ("NormalMap",2D) = "white" {}
        _NormalScale ("Normal" , range(0,1)) = 1
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
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 tToW0 : TEXCOORD1;
                float4 tToW1 : TEXCOORD2;
                float4 tToW2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            float _NormalScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _NormalMap);

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBitangent = cross(worldNormal,worldTangent)*v.tangent.w;

                o.tToW0 = float4(worldTangent.x,worldBitangent.x,worldNormal.x,worldPos.x);
                o.tToW1 = float4(worldTangent.y,worldBitangent.y,worldNormal.y,worldPos.y);
                o.tToW2 = float4(worldTangent.z,worldBitangent.z,worldNormal.z,worldPos.z);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed3 worldView = normalize(UnityWorldSpaceViewDir(float3(i.tToW0.w,i.tToW1.w,i.tToW2.w)));
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(float3(i.tToW0.w,i.tToW1.w,i.tToW2.w)));
                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;

                fixed4 packedNormal = tex2D(_NormalMap,i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                  tangentNormal.xy *= _NormalScale;
                tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                //fixed3 worldNormal = mul(fixed3x3(i.tToW0.xyz,i.tToW1.xyz,i.tToW2.xyz),tangentNormal);
                fixed3 worldNormal = normalize(half3(dot(i.tToW0.xyz,tangentNormal),dot(i.tToW1.xyz,tangentNormal),dot(i.tToW2.xyz,tangentNormal)));
              
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse * saturate(dot(worldNormal,worldLight));

                fixed3 halfDir = normalize(worldLight + worldView);
                fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
                
                
                return fixed4(ambient + diffuse + specular,1.0f);
            }
            ENDCG
        }
    }
}
