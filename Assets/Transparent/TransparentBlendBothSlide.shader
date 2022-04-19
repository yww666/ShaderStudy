Shader "Unlit/TransparentBlendBothSlide"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _AlphaScale("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            
            Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
           // Blend OneMinusDstColor One
           // Blend DstColor Zero
            
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
            fixed _AlphaScale;

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


                fixed3 diffuse = _LightColor0.rgb *  col.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
                
                
                return fixed4(ambient + diffuse,col.a * _AlphaScale);
            }
            ENDCG
        }

        
         Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
           // Blend OneMinusDstColor One
           // Blend DstColor Zero
            
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
            fixed _AlphaScale;

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


                fixed3 diffuse = _LightColor0.rgb *  col.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
                
                
                return fixed4(ambient + diffuse,col.a * _AlphaScale);
            }
            ENDCG
        }
    }
}
