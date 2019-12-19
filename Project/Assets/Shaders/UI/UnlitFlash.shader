// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unicorn/UI/Flash"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "black" {}
		_Mask ("Mask Alpha (A)", 2D) = "black" {}
		_IfMask("Open mask if larger than 0.5", Range(0,1)) = 0
		_TextureWidth("Texture.width", float) = 1
		_TextureHeight("Texture.height", float) = 1
		_XOffset("offsetX", float) = 0
		_YOffset("offsetY", float) = 0
		_MaskWidth ("Mask.width", float) = 1
		_MaskHeight ("Mask.height", float) = 1
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
		Blend DstColor DstAlpha

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
			float _TextureWidth;
			float _TextureHeight;
			float _XOffset; 
			float _YOffset; 
			float _IfMask; 
			float _MaskWidth;
			float _MaskHeight;
			int _Effect;
				
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				return o;
			}
				
			fixed4 frag (v2f i) : COLOR
			{
			    fixed4 col;
				float2 uv = float2(i.texcoord.x + _Time.x*10,i.texcoord.y);
				col = tex2D(_MainTex, uv ) * i.color;
				float2 uv_mask = float2((i.texcoord.x)*_TextureWidth/_MaskWidth, (i.texcoord.y)*_TextureHeight/_MaskHeight);
				float mask = tex2D(_Mask, uv_mask).a; 
				if(mask < 0.3) {
					col = fixed4(0,0,0,0);
				} else {
					col = fixed4(col.a,col.a,col.a,col.a)*0.8;
//					col = fixed4(1,1,1,col.a);
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
