Shader "Unlit/ToonShader"
{
    Properties
    {
        _OutLine ("OutLine",range(0,1)) =  1 
        _OutLineColor ("OutLineColor",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse",Color) = (1,1,1,1)
        _Step ("Step",range(1,30)) = 1
        _ToonEffect ("ToonEffect",Range(0,1)) = 0
        _RimColor ("RimColor",Color) = (1,1,1,1)
        _RimScale ("RimScale",range(0,100)) = 1
        _XRayRimColor ("XRayRimColor",Color) = (1,1,1,1)
        _XRayRimScale ("XRayRimScale",range(1,100)) = 1
    }
    SubShader
    {
        Tags {"Queue" = "Geometry+1000" "RenderType"="Opaque" }
        LOD 100
        
        
        Pass{
            
            Tags { "LightMode" = "ForwardBase" }
            
//            ZTest Greater
//            ZWrite Off
            Blend One Zero
            
            CGPROGRAM
            #pragma  vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _XRayRimColor;
            float _XRayRimScale;

            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
    
            };

             struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
 
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));

               // fixed rim =  dot(worldNormal,worldView);
               //  fixed4 rimColor = _XRayRimColor *  pow(1-rim,1/_XRayRimScale);
                
                return _XRayRimColor;
            
            }
            

            ENDCG
            
                
        }
        
        
        
//        Pass{
//            
//            Tags { "LightMode" = "ForwardBase" }
//            
//            Cull Front
//            
//            
//            CGPROGRAM
//            #pragma  vertex vert
//            #pragma fragment frag
//
//            #include "UnityCG.cginc"
//
//            float _OutLine;
//            fixed4 _OutLineColor;
//            
//            struct appdata
//            {
//                float4 vertex : POSITION;
//                float3 normal : NORMAL;
//    
//            };
//
//             struct v2f
//            {
//                float4 vertex : SV_POSITION;
//            };
//
//            v2f vert (appdata v)
//            {
//                v2f o;
//
//                v.vertex.xyz += v.normal * _OutLine;
//                o.vertex = UnityObjectToClipPos(v.vertex);
//
//  
// 
//                return o;
//            }
//
//
//            fixed4 frag(v2f i) : SV_Target
//            {
//
//                return _OutLineColor;
//            
//            }
//            
//
//            ENDCG
//            
//        }
//
//        Pass
//        {
//            
//            Tags { "LightMode" = "ForwardBase" }
//            
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            // make fog work
//
//            #include "UnityCG.cginc"
//            #include "Lighting.cginc"
//
//            struct appdata
//            {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//                float3 normal : NORMAL;
//            };
//
//            struct v2f
//            {
//                float2 uv : TEXCOORD0;
//                float4 vertex : SV_POSITION;
//                float3 worldPos : TEXCOORD1;
//                float3 worldNormal : TEXCOORD2;
//            };
//
//            sampler2D _MainTex;
//            float4 _MainTex_ST;
//            fixed4 _Diffuse;
//            float _Step;
//            fixed _ToonEffect;
//            fixed4 _RimColor;
//            float _RimScale;
//
//            v2f vert (appdata v)
//            {
//                v2f o;
//                o.vertex = UnityObjectToClipPos(v.vertex);
//                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//                o.worldNormal = UnityObjectToWorldNormal(v.normal);
//                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
//                return o;
//            }
//
//            fixed4 frag (v2f i) : SV_Target
//            {
//                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
//
//                fixed3 worldNormal = normalize(i.worldNormal);
//                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
//                fixed3 worldView= normalize(UnityWorldSpaceViewDir(i.worldPos));
//                
//                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
//
//
//                fixed3 dif = dot(worldNormal,worldLight) * 0.5 + 0.5;
//                dif = smoothstep(0,1,dif);
//
//                float toon = floor(dif * _Step) / _Step;
//
//                dif = lerp(dif,toon,_ToonEffect);
//
//                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * dif * albedo;
//
//                //边缘光
//                fixed rim = dot(worldView,worldNormal);
//
//                fixed4 rimColor = _RimColor * pow(1-rim,1/_RimScale);
//                
//                
//                return fixed4(diffuse + ambient + rimColor.rgb,1.0);
//            }
//            ENDCG
//        }
    }
}
