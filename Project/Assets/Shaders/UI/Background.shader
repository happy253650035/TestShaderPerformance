// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unicorn/UI/Background" {	
	
	Properties {
		//_MainTex ("Base (RGB)", 2D) = "white" {}
		_TintColor ("Tint Color",Color) = (1,1,1,1)
	}
	SubShader {
	
		//Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }
		LOD 100
		
        Pass {
        
		  	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
        	//Blend SrcAlpha One	
        	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//sampler2D _MainTex;
			//float4 _MainTex_ST;
			fixed4 _TintColor;

			struct appdata_t {
				float4 vertex : POSITION;
				
				//float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				
				//float2 texcoord : TEXCOORD0;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				//fixed4 col = _TintColor * tex2D(_MainTex, i.texcoord);
				return _TintColor;
			}

//			 float4 frag(v2f i) : COLOR
//			 {
//				float4 col = tex2D(_MainTex, i.uv);	
//				col *= _TintColor;
//			    return col;
//			 }

			 ENDCG
      }
   }

}
