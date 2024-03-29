// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unicorn/UI/Transparent Colored Mask"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_Mask ("Mask Alpha (A)", 2D) = "white" {}
		_IfMask("Open mask if larger than 0.5", Range(0,1)) = 0
		_WidthRate ("Sprite.width/Atlas.width", float) = 1
		_HeightRate ("Sprite.height/Atlas.height", float) = 1
		_XOffset("offsetX", float) = 0
		_YOffset("offsetY", float) = 0
		_Effect ("效果（_Effect）", Int) = 0
	}
	
	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Offset -1, -1
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
				
			#include "UnityCG.cginc"
	
			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
			};
	
			struct v2f
			{
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				fixed4 color : COLOR;
				fixed gray : TEXCOORD1; 
			};
	
			sampler2D _MainTex;
			sampler2D _Mask;
			float4 _MainTex_ST;
			float4 _Mask_ST;
			float _WidthRate;
			float _HeightRate;
			float _XOffset; 
			float _YOffset; 
			float _IfMask; 
			int _Effect;
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				o.gray = dot(v.color, fixed4(1,1,1,0));
				return o;
			}
				
			fixed4 frag (v2f i) : COLOR
			{
			    fixed4 col;
				
				col = tex2D(_MainTex, i.texcoord) * i.color;
				if(_IfMask>0.5){
					col.a = col.a * tex2D(_Mask, float2((i.texcoord.x-_XOffset)/_WidthRate, (i.texcoord.y-(1-_YOffset))/_HeightRate)).r; 
				}
				//灰度图
				if(_Effect == 1){
					float y = 0.2126 * col.r + 0.7152 * col.g + 0.0722 * col.b;
					col = fixed4(y, y, y, col.a);
				}			
				return col;
			}
			ENDCG
		}
	}

	SubShader
	{
		LOD 100

		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			Offset -1, -1
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMaterial AmbientAndDiffuse
			
			SetTexture [_MainTex]
			{
				Combine Texture * Primary
			}
		}
	}
}
