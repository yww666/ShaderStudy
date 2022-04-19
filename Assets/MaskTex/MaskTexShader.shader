Shader "Unlit/MaskTexShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("BumpMap", 2D) = "white" {}
        _BumpScale("BumpScale", float) = 1.0
        _Specular("Specular", Color) = (1,1,1,1)
        _SpecularMask("SpecularMask",2D) = "white" {}
        _SpecularScale("SpecularScale",float) = 1.0
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Gloss("Gloss",range(8,256)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 tangentLight: TEXCOORD1;
                float3 tangentView: TEXCOORD2;
                
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            sampler2D _SpecularMask;
            float _BumpScale;
            float _SpecularScale;
            float _Gloss;
            fixed4 _Specular;
            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 biTangent = cross(v.normal,v.tangent.xyz) * v.tangent.w;
                float3x3 rotation = {biTangent,v.tangent.xyz,v.normal};

                o.tangentLight = mul(rotation,ObjSpaceLightDir(v.vertex));
                o.tangentView = mul(rotation,ObjSpaceViewDir(v.vertex));
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed3 tangentLightDir = normalize(i.tangentLight);
                fixed3 tangentViewDir = normalize(i.tangentView);

                fixed3 albedo = tex2D(_MainTex,i.uv).rgb;

                float4 packBump = tex2D(_BumpMap,i.uv);
                fixed3 tangentNormal =  UnpackNormal(packBump);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - dot(tangentNormal.xy,tangentNormal.xy));

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));


                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss) * tex2D(_SpecularMask,i.uv).r * _SpecularScale;
                
                return fixed4(ambient + diffuse + specular,1.0f);
            }
            ENDCG
        }
    }
}
