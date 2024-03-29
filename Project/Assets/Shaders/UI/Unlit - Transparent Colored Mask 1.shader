// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unicorn/UI/Transparent Colored Mask 1"
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
		LOD 200

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
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			AlphaTest Greater .01
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

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
			
			float4 _ClipRange0 = float4(0.0, 0.0, 1.0, 1.0);
			float2 _ClipArgs0 = float2(1000.0, 1000.0);

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = v.vertex.xy * _ClipRange0.zw + _ClipRange0.xy;
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipArgs0;
			
				// Sample the texture
				half4 col = tex2D(_MainTex, IN.texcoord);

				
				if (dot(IN.color, fixed4(1,1,1,0)) == 0){
				  col = tex2D(_MainTex, IN.texcoord);
				  col.rgb = dot(col.rgb, fixed3(.222,.707,.071));
				}else{
				  col = col * IN.color;
				}
				
				if(col.a>0){
					col.a *= clamp( min(factor.x, factor.y), 0.0, 1.0);
				}
				
				if(col.a>0 && _IfMask>0.5){
					col.a = col.a * tex2D(_Mask, float2((IN.texcoord.x-_XOffset)/_WidthRate, (IN.texcoord.y-(1-_YOffset))/_HeightRate)).r; 
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
