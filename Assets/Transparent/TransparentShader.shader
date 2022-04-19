Shader "Unlit/TransparentShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _CutOff ("Alpha CutOff",range(0,1)) = 0.5 
    }
    SubShader
    {
        Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Diffuse;
            fixed _CutOff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));  


                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                
                fixed4 col = tex2D(_MainTex, i.uv);

                if(col.a - _CutOff < 0.0)
                {
                    discard;
                }

                fixed3 diffuse = _LightColor0.rgb *  col.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
                
                
                return fixed4(ambient + diffuse,1.0);
            }
            ENDCG
        }
    }
}
