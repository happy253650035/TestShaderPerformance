// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "RaceOL/Particle/Mobile_Particle_Add 1" {	
	
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ClipRange0("ClipRange0",Vector) = (0,0,1,1)
	}
	SubShader {
	
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		
		LOD 100
		
        Pass {
        
		  	Cull Off 
		  	Lighting Off 
		  	ZWrite Off 
		  	Fog { Color (0,0,0,0) }
        	//Blend One OneMinusSrcAlpha
        	//Blend One SrcAlpha
        	//Blend SrcAlpha OneMinusSrcAlpha
        	//Blend One Zero
        	Blend SrcAlpha One	
         	CGPROGRAM
 			
         	#pragma vertex vert  
         	#pragma fragment frag 
 			#pragma target 3.0

         	uniform sampler2D _MainTex;	
         	float4 _MainTex_ST;
         	uniform float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0); 
		 	
		 	
		 	#include "UnityCG.cginc"
		 	
		 	struct appdata_t {
		 		float4 vertex : POSITION;
		 		float4 texcoord : TEXCOORD0;	
		 		float4 color : COLOR;
		 	};
				
         	struct v2f {
         	   	float4 pos : POSITION;
         	   	float2 uv : TEXCOORD0;
         	   	float4 color : COLOR;
         	   	float4 screen : TEXCOORD1;
         	};
 			
         	v2f vert(appdata_t v) 
         	{
         	   	v2f o;
 			   	
         	   	o.pos = UnityObjectToClipPos (v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.screen = ComputeScreenPos(o.pos);
				o.color = v.color;
         	   	return o;
         	}
		 	
         	float4 frag(v2f i) : COLOR
         	{
				float4 col = tex2D(_MainTex, i.uv)* i.color;	
				float x = clamp( i.screen.x, _ClipRange0.x, _ClipRange0.x + _ClipRange0.z);
				if (abs(x - i.screen.x) <= 0.00001){
					col.a = col.a;
				}else{
					col.a = 0.0f;
				}
				float y = clamp( i.screen.y, _ClipRange0.y, _ClipRange0.y + _ClipRange0.w);
				if (abs(y - i.screen.y) <= 0.00001){
					col.a = col.a;
				}else{
					col.a = 0.0f;
				}
         	   return col;
         	}
 
         	ENDCG
     	}
   }
}
