Shader "ZJY/Role/CustomPBR_Role_VF" 
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "white" {}
		_Mask01Map("(R)Metallic (G)Smoothness (B)Occlusion (A)Bloom", 2D) = "white" {}
		//_Glossiness ("Smoothness", Range(0,1)) = 0.5
		//_Metallic ("Metallic", Range(0,1)) = 0.0
		[Space(18)]
		_LightColor("Light Color",Color)=(1,1,1,1)
		_LightIntensity("Light Intensity",Range(0,1.5))=1
		[Space(18)]
		[HDR]
		_BloomColor("Bloom Color",Color)=(1,1,1,1)
		[Space(18)]
		 _MetallicRemappingLow("MetallicRemappingLow",Range(0.01,1))=0.01
		_MetallicRemappingHigh("MetallicRemappingHigh",Range(0.02,1))=1
		[HideInInspector]_MetallicRemappingLevelLow("MetallicRemappingLevelLow",Range(0,1))=0
        [HideInInspector]_MetallicRemappingLevelHigh("MetallicRemappingLevelHigh",Range(0,1))=1
		_SmoothnessRemappingLow("SmoothnessRemappingLow",Range(0.01,1))=0.01
		_SmoothnessRemappingHigh("SmoothnessRemappingHigh",Range(0.02,1))=1
		[HideInInspector]_SmoothnessRemappingLevelLow("SmoothnessRemappingLevelLow",Range(0,1))=0
        [HideInInspector]_SmoothnessRemappingLevelHigh("SmoothnessRemappingLevelHigh",Range(0,1))=1
		[Space(18)]
		_EnvironmentTex ("Reflection CubeMap", Cube) = "black" {}
		_EnvironmentRotation("EnvironmentRotation(0-360)",Range(0,360))=1
		_EnvReflectionIntensity("Enviroment Reflection Intensity",Range(0.01,2))=1
		_EnvAmbientIntensity("Enviroment Ambient Intensity",Range(0.01,2))=1
		//_PointDir("Point Direction",Vector)=(0,0,0,0)
		//_PointLightColor("Point Light Color",Color)=(1,1,1,1)
		//_PointIntensity("Point Intensity",Range(0,10))=1
		//_PointAtten("Point Attenuation" ,Range(0,1))=0.5
		[HideInInspector]_SHAr ("First Order Harmonic_SHAr", Vector) = (0.1410518,0.1996599,-0.1916448,0.4627451) 
		[HideInInspector]_SHAg ("First Order Harmonic_SHAg", Vector) = (0.1914412,0.3132915,-0.251553,0.5294118) 
		[HideInInspector]_SHAb ("First Order Harmonic_SHAb", Vector) = (0.2108869,0.4276009,-0.2584893,0.5372549) 

		[HideInInspector]_SHBr ("Second Order Harmonic_SHBr", Vector) = (0.04257296,-0.1443495,0.1463619,0.0) 
		[HideInInspector]_SHBg ("Second Order Harmonic_SHBg", Vector) = (0.06174606,-0.1617367,0.1746086,0.0) 
		[HideInInspector]_SHBb ("Second Order Harmonic_SHBb", Vector) = (0.07339491,-0.1538019,0.173522,0.0) 

		[HideInInspector]_SHC ("Third OrderHarmonic_SHC", Vector) = (0.06419951,0.06835041,0.05078474,1.0)
		[Space(18)]
		_OcclusionIntensity("Occlusion Intensity" ,Range(0,1))=1

	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass
		{
			Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc" 
            struct v2f
            {
				 V2F_SHADOW_CASTER;

			};
              
            v2f vert( appdata_base  v)
            {
				v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;

			}
                
            half4  frag(v2f i):SV_Target
            {
				 SHADOW_CASTER_FRAGMENT(i)
			}
            ENDCG
		}

		Pass 
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			Fog { Mode Off }
			CGPROGRAM
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			//#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase 
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "AutoLight.cginc"
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

			sampler2D _MainTex;

			struct Input 
			{
				half2 uv_MainTex;
				half2 uv_BumpMap;
				half2 uv_Mask01Map;

			};

			sampler2D  _BumpMap;
			sampler2D  _Mask01Map;	
			fixed4 _Color;
			fixed4 _BloomColor;
			fixed _SmoothnessRemappingLow;
			fixed _SmoothnessRemappingHigh;
			fixed _SmoothnessRemappingLevelLow;
			fixed _SmoothnessRemappingLevelHigh;

			fixed _MetallicRemappingLow;
			fixed _MetallicRemappingHigh;
            
			fixed _MetallicRemappingLevelLow;
			fixed _MetallicRemappingLevelHigh;

			half4 _EnvironmentTex_HDR;
			half _EnvironmentRotation;
			samplerCUBE _EnvironmentTex;
			half _EnvReflectionIntensity;
			half _EnvAmbientIntensity;
			//fixed4 _PointDir;
			//fixed4 _PointLightColor;
			//half _PointIntensity;
			//half _PointAtten;
			uniform half4 _SHAr;
			uniform half4 _SHAg;
			uniform half4 _SHAb; 

			uniform half4 _SHBr;
			uniform half4 _SHBg;
			uniform half4 _SHBb;

			uniform half4 _SHC;
			half _OcclusionIntensity;
			half3 _LightColor;
			half _LightIntensity;

			/*half3 My_SHEvalLinearL0L1 (half4 normal)
			{
				half3 x;

				// Linear (L1) + constant (L0) polynomial terms
				x.r = dot(_SHAr,normal);
				x.g = dot(_SHAg,normal);
				x.b = dot(_SHAb,normal);
			    //x=GammaToLinearSpace(x);
				return x;
			}*/


			void surf (Input IN, inout SurfaceOutputStandard o) 
			{
				//unity_SpecCube0=_aa;
				o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
				half f_smoothness=(_SmoothnessRemappingLevelHigh-_SmoothnessRemappingLevelLow)/(_SmoothnessRemappingHigh-_SmoothnessRemappingLow);
				half f_metallic=(_MetallicRemappingLevelHigh-_MetallicRemappingLevelLow)/(_MetallicRemappingHigh-_MetallicRemappingLow);
				fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
				fixed4 mask01 = tex2D (_Mask01Map, IN.uv_Mask01Map);

				c.rgb=GammaToLinearSpace(c.rgb);
				//mask01.rgb=LinearToGammaSpace(mask01.rgb);
				//mask01.rgb=saturate(mask01.rgb);
				fixed3 bloomMask=fixed3(mask01.a,mask01.a,mask01.a);
				//bloomMask=GammaToLinearSpace(bloomMask);

				fixed remappingMetallic=(mask01.r-_MetallicRemappingLow)*f_metallic;
				remappingMetallic=clamp(remappingMetallic,0,1);
				fixed remappingSmoothness=(mask01.g-_SmoothnessRemappingLow)*f_smoothness;
				remappingSmoothness=clamp(remappingSmoothness,0,1);
				o.Albedo =c.rgb;
				//o.Albedo=bloomMask;
				o.Metallic = remappingMetallic;
				o.Smoothness = remappingSmoothness;
				o.Alpha = c.a;
				o.Occlusion=saturate(mask01.b+(1-_OcclusionIntensity));
				o.Emission=bloomMask*_BloomColor;
			}

			struct v2f_surf 
			{
				UNITY_POSITION(pos);
				half4 pack0 : TEXCOORD0; // _MainTex _BumpMap
				half2 pack1 : TEXCOORD1; // _Mask01Map
				half4 tSpace0 : TEXCOORD2;
				half4 tSpace1 : TEXCOORD3;
				half4 tSpace2 : TEXCOORD4;
				#if UNITY_SHOULD_SAMPLE_SH
					half3 sh : TEXCOORD5; // SH
				#endif
				UNITY_SHADOW_COORDS(6)
			};
			half4 _MainTex_ST;
			half4 _BumpMap_ST;
			half4 _Mask01Map_ST;

			// vertex shader
			v2f_surf vert_surf (appdata_full v) 
			{
				v2f_surf o;
				UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.pack0.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				o.pack1.xy = TRANSFORM_TEX(v.texcoord, _Mask01Map);
				half3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				
				UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
				return o;
			}

			
			half3 MY_Unity_GlossyEnvironment(half4 hdr, Unity_GlossyEnvironmentData glossIn)
			{
				half perceptualRoughness = glossIn.roughness /* perceptualRoughness */ ;
				perceptualRoughness = perceptualRoughness*(1.7 - 0.7*perceptualRoughness);
				half mip = perceptualRoughnessToMipmapLevel(perceptualRoughness);
				half3 R = glossIn.reflUVW;
				half3x3 rotationMatrix = half3x3(cos(_EnvironmentRotation/57.32f), 0, sin(_EnvironmentRotation/57.32f),0, 1, 0,-sin(_EnvironmentRotation/57.32f), 0, cos(_EnvironmentRotation/57.32f));
				half4 rgbm = texCUBElod(_EnvironmentTex, half4(mul(R,rotationMatrix), mip));
				return DecodeHDR(rgbm, hdr);
			}





			inline half3 MY_UnityGI_IndirectSpecular(UnityGIInput data, half occlusion, Unity_GlossyEnvironmentData glossIn)
			{
				half3 specular;
				//half3 env0 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), data.probeHDR[0], glossIn);
				half3 env0=MY_Unity_GlossyEnvironment(_EnvironmentTex_HDR,glossIn);
				specular = env0;
				return specular;
			}

			inline UnityGI MY_UnityGI_Base(UnityGIInput data, half occlusion, half3 normalWorld,half3 lightColor,half lightIntensity)
			{
				UnityGI o_gi;
				ResetUnityGI(o_gi);

				// Base pass with Lightmap support is responsible for handling ShadowMask / blending here for performance reason
				/*#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
					half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
					float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
					float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
					data.atten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
				#endif*/

				o_gi.light = data.light;
				o_gi.light.color=lightColor*lightIntensity;
				o_gi.light.color *= data.atten;

				#if UNITY_SHOULD_SAMPLE_SH
					/*//o_gi.indirect.diffuse = ShadeSHPerPixel (normalWorld, data.ambient, data.worldPos);
					half3 ambient=0.0;
					ambient=My_SHEvalLinearL0L1(half4(normalWorld,1))*_EnvAmbientIntensity;
					//ambient = GammaToLinearSpace (ambient);
					#ifdef UNITY_COLORSPACE_GAMMA
						ambient = LinearToGammaSpace (ambient);
					#endif
				    o_gi.indirect.diffuse=ambient;*/

						//x.r = dot(_SHAr,normal);
						//x.g = dot(_SHAg,normal);
						//x.b = dot(_SHAb,normal);
						////x=GammaToLinearSpace(x);
						//return x;








					float3 x1, x2, x3;
					float4 wN = float4(normalWorld, 1);
					x1.r = dot(_SHAr,wN);
					x1.g = dot(_SHAg,wN);
					x1.b = dot(_SHAb,wN);

					// 4 of the quadratic polynomials
					half4 vB = wN.xyzz * wN.yzzx;
					x2.r = dot(_SHBr,vB);
					x2.g = dot(_SHBg,vB);
					x2.b = dot(_SHBb,vB);

					// Final quadratic polynomial
					float vC = wN.x*wN.x - wN.y*wN.y;
					x3 = _SHC.rgb * vC;

					float3 shC = (x1 + x2 + x3) ;
					shC = shC*GammaToLinearSpace( _EnvAmbientIntensity);
					o_gi.indirect.diffuse = shC;



				#endif

				/*#if defined(LIGHTMAP_ON)
					// Baked lightmaps
					half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, data.lightmapUV.xy);
					half3 bakedColor = DecodeLightmap(bakedColorTex);

					#ifdef DIRLIGHTMAP_COMBINED
						fixed4 bakedDirTex = UNITY_SAMPLE_TEX2D_SAMPLER (unity_LightmapInd, unity_Lightmap, data.lightmapUV.xy);
						o_gi.indirect.diffuse = DecodeDirectionalLightmap (bakedColor, bakedDirTex, normalWorld);

						#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
							ResetUnityLight(o_gi.light);
							o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap (o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
						#endif

					#else // not directional lightmap
						o_gi.indirect.diffuse = bakedColor;

						#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
							ResetUnityLight(o_gi.light);
							o_gi.indirect.diffuse = SubtractMainLightWithRealtimeAttenuationFromLightmap(o_gi.indirect.diffuse, data.atten, bakedColorTex, normalWorld);
						#endif

					#endif
				#endif

				 #ifdef DYNAMICLIGHTMAP_ON
					// Dynamic lightmaps
					fixed4 realtimeColorTex = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, data.lightmapUV.zw);
					half3 realtimeColor = DecodeRealtimeLightmap (realtimeColorTex);

					#ifdef DIRLIGHTMAP_COMBINED
						half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, data.lightmapUV.zw);
						o_gi.indirect.diffuse += DecodeDirectionalLightmap (realtimeColor, realtimeDirTex, normalWorld);
					#else
						o_gi.indirect.diffuse += realtimeColor;
					#endif
				#endif*/

				o_gi.indirect.diffuse *= occlusion;
				return o_gi;
			}

			
			half4 BRDF2_Cstuom_PBS (half3 diffColor, half3 specColor, half oneMinusReflectivity, half smoothness,
				half3 normal, float3 viewDir,
				UnityLight light,UnityIndirect gi)
			{

				//gi.diffuse=GammaToLinearSpace(gi.diffuse);
				gi.specular=GammaToLinearSpace(gi.specular);
				light.color=GammaToLinearSpace(light.color);
				half3 halfDir = Unity_SafeNormalize (float3(light.dir) + viewDir);

				half nl = saturate(dot(normal, light.dir));
				half nh = saturate(dot(normal, halfDir));
				half nv = saturate(dot(normal, viewDir));
				float lh = saturate(dot(light.dir, halfDir));

				// Specular term
				half perceptualRoughness = SmoothnessToPerceptualRoughness (smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

			#if UNITY_BRDF_GGX

				// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
				// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
				// https://community.arm.com/events/1155
				half a = roughness;
				half a2 = a*a;

				half d = nh * nh * (a2 - 1.f) + 1.00001f;
			#ifdef UNITY_COLORSPACE_GAMMA
				// Tighter approximation for Gamma only rendering mode!
				// DVF = sqrt(DVF);
				// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(roughness + .5) * d);
				half specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);
			#else
				half specularTerm = a2 / (max(0.1f, lh*lh) * (roughness + 0.5f) * (d * d) * 4);
			#endif

				// on mobiles (where half actually means something) denominator have risk of overflow
				// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
				// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
			#if defined (SHADER_API_MOBILE)
				specularTerm = specularTerm - 1e-4f;
			#endif

			#else

				// Legacy
				half specularPower = PerceptualRoughnessToSpecPower(perceptualRoughness);
				// Modified with approximate Visibility function that takes roughness into account
				// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
				// and produced extremely bright specular at grazing angles

				half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
				half invF = lh;

				half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);

			#ifdef UNITY_COLORSPACE_GAMMA
				specularTerm = sqrt(max(1e-4f, specularTerm));
			#endif

			#endif

			#if defined (SHADER_API_MOBILE)
				specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
			#endif
			#if defined(_SPECULARHIGHLIGHTS_OFF)
				specularTerm = 0.0;
			#endif

				// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)

				// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
				// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
			#ifdef UNITY_COLORSPACE_GAMMA
				half surfaceReduction = (0.6-0.08*perceptualRoughness);
			#else
				half surfaceReduction = (0.6-0.08*perceptualRoughness);
			#endif

				surfaceReduction = 1.0 - roughness*perceptualRoughness*surfaceReduction;

				half grazingTerm = saturate(smoothness + (1-oneMinusReflectivity));
				half3 color =   (diffColor + specularTerm * specColor) * light.color * nl
                    + gi.diffuse * diffColor
                    + surfaceReduction * gi.specular * FresnelLerpFast (specColor, grazingTerm, nv);

				return half4(color, 1);
			}





			inline void LightingCustomStandard_GI(SurfaceOutputStandard s,UnityGIInput data,inout UnityGI gi)
			{
				Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, lerp(unity_ColorSpaceDielectricSpec.rgb, s.Albedo, s.Metallic));
				gi = MY_UnityGI_Base(data, s.Occlusion, s.Normal,_LightColor,_LightIntensity);
				gi.indirect.specular = MY_UnityGI_IndirectSpecular(data, s.Occlusion, g)*_EnvReflectionIntensity;
			}

			inline half4 LightingCustomStandard (SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
			{
				s.Normal = normalize(s.Normal);

				half oneMinusReflectivity;
				half3 specColor;


				s.Albedo = DiffuseAndSpecularFromMetallic (s.Albedo, s.Metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);


				// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
				// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
				half outputAlpha;
				s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

				half4 c = BRDF2_Cstuom_PBS (s.Albedo, specColor, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
				c.a = outputAlpha;

				c.rgb=LinearToGammaSpace(c.rgb);
				return c;
   
				//return fixed4(specColor,1);

			}

















			// fragment shader
			fixed4 frag_surf (v2f_surf IN) : SV_Target 
			{
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT(Input,surfIN);
				surfIN.uv_MainTex.x = 1.0;
				surfIN.uv_BumpMap.x = 1.0;
				surfIN.uv_Mask01Map.x = 1.0;
				surfIN.uv_MainTex = IN.pack0.xy;
				surfIN.uv_BumpMap = IN.pack0.zw;
				surfIN.uv_Mask01Map = IN.pack1.xy;
				half3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#ifdef UNITY_COMPILER_HLSL
					SurfaceOutputStandard o = (SurfaceOutputStandard)0;
				#else
				SurfaceOutputStandard o;
				#endif
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Alpha = 0.0;
				o.Occlusion = 1.0;
				fixed3 normalWorldVertex = fixed3(0,0,1);
				o.Normal = fixed3(0,0,1);

				// call surface function
				surf (surfIN, o);

				// compute lighting & shadowing factor
				UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				fixed4 c = 0;
				half3 worldN;
				worldN.x = dot(IN.tSpace0.xyz, o.Normal);
				worldN.y = dot(IN.tSpace1.xyz, o.Normal);
				worldN.z = dot(IN.tSpace2.xyz, o.Normal);
				worldN = normalize(worldN);
				o.Normal = worldN;

				// Setup lighting environment
				 UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				gi.light.color = _LightColor0.rgb;
				gi.light.dir = lightDir;
				// Call GI (lightmaps/SH/reflections) lighting function
				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = worldPos;
				giInput.worldViewDir = worldViewDir;
				giInput.atten = atten;
				#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
				giInput.ambient = IN.sh;
				 #else
				giInput.ambient.rgb = 0.0;
				 #endif
				//giInput.probeHDR[0] = unity_SpecCube0_HDR;
				//giInput.probeHDR[1] = unity_SpecCube1_HDR;
				LightingCustomStandard_GI(o, giInput, gi);
				// realtime lighting: call lighting function
				c += LightingCustomStandard (o, worldViewDir, gi);
				c.rgb += o.Emission;
				UNITY_OPAQUE_ALPHA(c.a);

				//fixed3 aa=My_SHEvalLinearL0L1(fixed4(o.Normal,1));
				//aa=GammaToLinearSpace(aa);
				//aa=LinearToGammaSpace(aa);
				/*fixed4 cc = tex2D (_MainTex, surfIN.uv_MainTex) * _Color;
				cc.rgb=GammaToLinearSpace(cc.rgb);*/
				//o.Albedo=LinearToGammaSpace(o.Albedo);



				return c;
				//return fixed4(My_SHEvalLinearL0L1(half4(o.Normal,1))*_EnvAmbientIntensity,1);

			
			}
			ENDCG
		}
	}
	FallBack "ZJY/DDZReplaceDefault"
}
