Shader "Unlit/TangentNormalMapShader"
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float3 tangentLight : TEXCOORD1;
                float3 tangentView : TEXCOORD2;
 
             
                float4 vertex : SV_POSITION;
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
                o.uv.zw = TRANSFORM_TEX(v.uv,_NormalMap);

                float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
                
                float3x3 rotation = {v.tangent.xyz,binormal,v.normal};

                //o.tangentNormal = mul(rotation,v.normal);
                o.tangentView = mul(rotation,ObjSpaceViewDir(v.vertex));
                o.tangentLight = mul(rotation,ObjSpaceLightDir(v.vertex));
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb;
                fixed4 packedNormal = tex2D(_NormalMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _NormalScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                fixed3 tangentLight = normalize(i.tangentLight);
                fixed3 tangentView = normalize(i.tangentView);

                fixed3 diffuse = _LightColor0.rgb * albedo * _Diffuse.rgb * saturate(dot(tangentNormal,tangentLight));

                fixed3 halfDir = normalize(tangentLight + tangentView);
                fixed3 specular = _LightColor0.rgb * _Specular * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                return fixed4(ambient + diffuse + specular,1.0f);
            }
            ENDCG
        }
    }
}
