// Upgrade NOTE: replaced 'defined NEUTRAL_ON' with 'defined (NEUTRAL_ON)'

// Upgrade NOTE: replaced 'defined NEUTRAL_ON' with 'defined (NEUTRAL_ON)'

Shader "ZJY/PostProcess/FastMobileBloomAndToneMapping"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BloomTex ("Bloom (RGB)", 2D) = "black" {}
		_AATex ("AA (RGB)", 2D) = "black" {}
	}
	CGINCLUDE
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma target 3.0 
		#pragma multi_compile __ ACES_ON 
		#pragma multi_compile __ NEUTRAL_ON
		#pragma multi_compile __ FXAA_ON
		#include "UnityCG.cginc"
		#if defined(SHADER_API_PS3)
            #define FXAA_PS3 1
            // Shaves off 2 cycles from the shader
            #define FXAA_EARLY_EXIT 0
        #elif defined(SHADER_API_XBOX360)
            #define FXAA_360 1

            // Shaves off 10ms from the shader's execution time
            #define FXAA_EARLY_EXIT 1
        #else
            #define FXAA_PC 1
        #endif

        #define FXAA_HLSL_3 1
        #define FXAA_QUALITY__PRESET 10

        #define FXAA_GREEN_AS_LUMA 1
		#include "FXAA3.cginc"
		uniform sampler2D _MainTex;
		uniform half4 _MainTex_TexelSize;
		uniform	half4 _MainTex_ST;
		uniform half2 _ThresholdParams;
		uniform half  _Spread;
		uniform sampler2D _BloomTex;
		uniform half _BloomIntensity;
		uniform sampler2D _AATex;
		//ACES
		uniform half _LumAdjust;

		//NEUTRAL
		uniform half _Exposure;
		uniform half4 _NeutralTonemapperParams1;
		uniform half4 _NeutralTonemapperParams2;

		uniform float3 _QualitySettings;
		uniform float4 _ConsoleSettings;

	
		struct v2fCombineBloom
		{
			float4 pos : SV_POSITION; 
			half2  uv  : TEXCOORD0;
			#if UNITY_UV_STARTS_AT_TOP
				half2  uv2 : TEXCOORD1;
			#endif
		};	

		struct v2fBlurDown
		{
			float4 pos  : SV_POSITION;
			half2  uv0  : TEXCOORD0;
			half4  uv12 : TEXCOORD1;
			half4  uv34 : TEXCOORD2;
		};

		struct v2fBlurUp
		{
			float4 pos  : SV_POSITION;
			half4  uv12 : TEXCOORD0;
			half4  uv34 : TEXCOORD1;
			half4  uv56 : TEXCOORD2;
			half4  uv78 : TEXCOORD3;
		};






		struct Input
		{
			float4 position : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct Varying
		{
			float4 position : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		Varying vertFXAA(Input input)
		{
			Varying output;
			output.position = UnityObjectToClipPos(input.position);
			output.uv = input.uv;
			return output;
		}


		 fixed4 fragFXAA(Varying input) : SV_Target
        {
            const float4 consoleUV = input.uv.xyxy + .5 * float4(-_MainTex_TexelSize.xy, _MainTex_TexelSize.xy);
            const float4 consoleSubpixelFrame = _ConsoleSettings.x * float4(-1., -1., 1., 1.) *
                _MainTex_TexelSize.xyxy;

            const float4 consoleSubpixelFramePS3 = float4(-2., -2., 2., 2.) * _MainTex_TexelSize.xyxy;
            const float4 consoleSubpixelFrameXBOX = float4(8., 8., -4., -4.) * _MainTex_TexelSize.xyxy;

            #if defined(SHADER_API_XBOX360)
                const float4 consoleConstants = float4(1., -1., .25, -.25);
            #else
                const float4 consoleConstants = float4(0., 0., 0., 0.);
            #endif

            return FxaaPixelShader(input.uv, consoleUV, _MainTex, _MainTex, _MainTex, _MainTex_TexelSize.xy,
                consoleSubpixelFrame, consoleSubpixelFramePS3, consoleSubpixelFrameXBOX,
                _QualitySettings.x, _QualitySettings.y, _QualitySettings.z, _ConsoleSettings.y, _ConsoleSettings.z,
                _ConsoleSettings.w, consoleConstants);

	
        }




		v2fBlurDown vertBlurDown(appdata_img v)
		{
			v2fBlurDown o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv0 = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy, _MainTex_ST);
			o.uv12.xy = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 1.0h,  1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv12.zw = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2(-1.0h,  1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv34.xy = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2(-1.0h, -1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv34.zw = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 1.0h, -1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			return o;
		}

		v2fBlurUp vertBlurUp(appdata_img v)
		{
			v2fBlurUp o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv12.xy = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 1.0h,  1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv12.zw = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2(-1.0h,  1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv34.xy = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2(-1.0h, -1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv34.zw = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 1.0h, -1.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv56.xy = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 0.0h,  2.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv56.zw = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 0.0h, -2.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv78.xy = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2( 2.0h,  0.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			o.uv78.zw = UnityStereoScreenSpaceUVAdjust(v.texcoord.xy + half2(-2.0h,  0.0h) * _MainTex_TexelSize.xy * _Spread, _MainTex_ST);
			return o;
		}

		v2fCombineBloom vertCombineBloomToneMapping(appdata_img v)
		{
			v2fCombineBloom o;
	
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = UnityStereoScreenSpaceUVAdjust(v.texcoord, _MainTex_ST);
			#if UNITY_UV_STARTS_AT_TOP
				o.uv2 = o.uv;
				if (_MainTex_TexelSize.y < 0.0)
					o.uv.y = 1.0 - o.uv.y;
			#endif

			return o;
		}

		fixed4 fragBlurDownFirstPass(v2fBlurDown i) : SV_Target
		{
			fixed4 col0 = tex2D(_MainTex, i.uv0);
			fixed4 col1 = tex2D(_MainTex, i.uv12.xy);
			fixed4 col2 = tex2D(_MainTex, i.uv12.zw);
			fixed4 col3 = tex2D(_MainTex, i.uv34.xy);
			fixed4 col4 = tex2D(_MainTex, i.uv34.zw);

			fixed4 col = col0 + col1*0.25 + col2*0.25 + col3*0.25 + col4*0.25;
			col = col * 0.5;
			col = col + _ThresholdParams.y;

			col = max(col, 0.0);
			return col;
		}

		fixed4 fragBlurDown(v2fBlurDown i) : SV_Target
		{
			fixed4 col0 = tex2D(_MainTex, i.uv0);
			fixed4 col1 = tex2D(_MainTex, i.uv12.xy);
			fixed4 col2 = tex2D(_MainTex, i.uv12.zw);
			fixed4 col3 = tex2D(_MainTex, i.uv34.xy);
			fixed4 col4 = tex2D(_MainTex, i.uv34.zw);

			fixed4 col = col0 + col1*0.25 + col2*0.25 + col3*0.25 + col4*0.25;
			col = col * 0.5;
			return col;
		}

		#define oneSix     0.1666666
		#define oneThree   0.3333333
		fixed4 fragBlurUp(v2fBlurUp i) : SV_Target
		{
			fixed4 col1 = tex2D(_MainTex, i.uv12.xy);
			fixed4 col2 = tex2D(_MainTex, i.uv12.zw);
			fixed4 col3 = tex2D(_MainTex, i.uv34.xy);
			fixed4 col4 = tex2D(_MainTex, i.uv34.zw);
			fixed4 col5 = tex2D(_MainTex, i.uv56.xy);
			fixed4 col6 = tex2D(_MainTex, i.uv56.zw);
			fixed4 col7 = tex2D(_MainTex, i.uv78.xy);
			fixed4 col8 = tex2D(_MainTex, i.uv78.zw);

			fixed4 col = col1*oneThree + col2*oneThree + col3*oneThree + col4*oneThree + col5*oneSix + col6*oneSix + col7*oneSix + col8*oneSix;
			//col = col * 0.5;

			return col;
		}

		half3 neutralCurve(half3 x, half a, half b, half c, half d, half e, half f)
		{
			return ((x * (a * x + c * b) + d * e) / (x * (a * x + b) + d * f)) - e / f;
		}


		half3 tonemapNeutral(half3 color)
		{
			color=GammaToLinearSpace(color);
			color *= _Exposure;

			// Tonemap
			half a = _NeutralTonemapperParams1.x;
			half b = _NeutralTonemapperParams1.y;
			half c = _NeutralTonemapperParams1.z;
			half d = _NeutralTonemapperParams1.w;
			half e = _NeutralTonemapperParams2.x;
			half f = _NeutralTonemapperParams2.y;
			half whiteLevel = _NeutralTonemapperParams2.z;
			half whiteClip = _NeutralTonemapperParams2.w;

			half3 whiteScale = (1.0).xxx / neutralCurve(whiteLevel, a, b, c, d, e, f);
			color = neutralCurve(color * whiteScale, a, b, c, d, e, f);
			color *= whiteScale;

			// Post-curve white point adjustment
			color = color / whiteClip.xxx;

			return LinearToGammaSpace(color);
		}


		fixed3 ACESToneMapping(float3 color, float adapted_lum)
		{
			color=GammaToLinearSpace(color);
			const float A = 2.51f;
			const float B = 0.03f;
			const float C = 2.43f;
			const float D = 0.59f;
			const float E = 0.14f;
			color *= adapted_lum;
			return LinearToGammaSpace((color * (A * color + B)) / (color * (C * color + D) + E));
		}


		fixed4 fragCombineBloomAndToneMapping(v2fCombineBloom i) : SV_Target
		{
			#if UNITY_UV_STARTS_AT_TOP
				fixed4 col = tex2D(_AATex,  i.uv2);
				col+=tex2D(_BloomTex, i.uv) * _BloomIntensity;
				#ifdef ACES_ON
					fixed3 finalCol=ACESToneMapping(col.rgb,_LumAdjust);
					return fixed4(finalCol,1);
				#elif NEUTRAL_ON
					fixed3 finalCol=tonemapNeutral(col.rgb);
					return fixed4(finalCol,1);
				#endif
					//return fixed4(0,0,1,1);
					return col;
			#else
				fixed4 col = tex2D(_AATex,  i.uv);
				col+=tex2D(_BloomTex, i.uv) * _BloomIntensity;
				#ifdef ACES_ON
					fixed3 finalCol=ACESToneMapping(col.rgb,_LumAdjust);
					return fixed4(finalCol,1);
				#elif NEUTRAL_ON
					fixed3 finalCol=tonemapNeutral(col.rgb);
					return fixed4(finalCol,1);
				#endif
				//return fixed4(0,0,1,1);
				return col;
			#endif
			//return tex2D(_AATex,  i.uv2);
			//return fixed4(1,0,0,1);
		}

	ENDCG


	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		Fog { Mode off }
		//initial downscale and threshold
		Pass
		{
			CGPROGRAM
			#pragma vertex vertBlurDown
			#pragma fragment fragBlurDownFirstPass
			ENDCG
		}

		//down pass
		Pass
		{
			CGPROGRAM
			#pragma vertex vertBlurDown
			#pragma fragment fragBlurDown
			ENDCG
		}

		//up pass
		Pass
		{
			CGPROGRAM
			#pragma vertex vertBlurUp
			#pragma fragment fragBlurUp
			ENDCG
		}

		//final bloom
		Pass
		{
			CGPROGRAM
			#pragma vertex vertCombineBloomToneMapping
			#pragma fragment fragCombineBloomAndToneMapping
			ENDCG
		}

		//AA
		 Pass
        {
            CGPROGRAM
                #pragma vertex vertFXAA
                #pragma fragment fragFXAA
            ENDCG
        }
		
	}
}