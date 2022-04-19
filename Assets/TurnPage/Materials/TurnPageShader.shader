Shader "Unlit/TurnPageShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainTex2 ("Texture2", 2D) = "white" {}
        _RotAngle ("RotAngle",Range(0,180)) = 0
        _RotAngle2 ("RotAngle",Range(0,180)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        
        Pass{
            
        Tags { "LightMode" = "ForwardBase" }
            
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex2;
            float4 _MainTex2_ST;
      
            float _RotAngle2;

            v2f vert (appdata v)
            {
                           v2f o;
                //float radian = radians(_RotAngle);
                float sins;
                float coss;
                sincos(radians(_RotAngle2),sins,coss);
                fixed4x4 zRot = {coss,-sins,0,0,
                                sins,coss,0,0,
                                0,0,1,0,
                                0,0,0,1.
                };

                v.vertex.x -= float4(5,0,0,0);
                v.vertex.y = sin(v.vertex.x * 0.5) * sins;
                v.vertex = mul(v.vertex,zRot);
                v.vertex.x += float4(5,0,0,0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex2);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex2, i.uv);
                // apply fog
                return fixed4(col.rgb,1);
            }
            ENDCG
            
            
                
        }
        

        Pass
        {
            
            Tags { "LightMode" = "ForwardBase" }
            
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _RotAngle;

            v2f vert (appdata v)
            {
                v2f o;
                //float radian = radians(_RotAngle);
                float sins;
                float coss;
                sincos(radians(_RotAngle),sins,coss);
                fixed4x4 zRot = {coss,-sins,0,0,
                                sins,coss,0,0,
                                0,0,1,0,
                                0,0,0,1.
                };

                v.vertex.x -= float4(5,0,0,0);
                v.vertex.y = sin(v.vertex.x * 0.5) * sins;
                v.vertex = mul(v.vertex,zRot);
                v.vertex.x += float4(5,0,0,0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                return fixed4(col.rgb,1);
            }
            ENDCG
        }
    }
}
