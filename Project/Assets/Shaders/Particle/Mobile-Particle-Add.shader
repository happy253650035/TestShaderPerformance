// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "RaceOL/Particle/Mobile_Particle_Add" {	
	
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
	
		Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }
		
		LOD 100
		
        Pass {
        
		  	Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
        	//Blend One OneMinusSrcAlpha
        	//Blend One SrcAlpha
        	//Blend SrcAlpha OneMinusSrcAlpha
        	//Blend One Zero
        	Blend SrcAlpha One	
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         sampler2D _MainTex;	
         float4 _MainTex_ST;

		 

		 #include "UnityCG.cginc"

		struct appdata_t {
			    float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;	
				fixed4 color : COLOR;
		};
		
         struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            fixed4 color : COLOR;
         };
 
         v2f vert(appdata_t v) 
         {
            v2f o;
 
            o.pos = UnityObjectToClipPos (v.vertex);
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.color = v.color;
            return o;
         }

         float4 frag(v2f i) : COLOR
         {
			float4 col = tex2D(_MainTex, i.uv) * i.color;	
            return col;
         }
 
         ENDCG
      }
   }

}
