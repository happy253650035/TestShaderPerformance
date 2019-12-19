Shader "ZJY/Role/CustomPBR_RoleSkin_VF"
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_SpecTex ("Specular Tex", 2D) = "black" {}
		_BeckmannTex ("Beckmann Tex", 2D) = "black" {}
		_SkinColor ("Skin Color", Color) = (1,1,1,1)
		_SSSLUT ("SSSLUT", 2D) = "white" {}
		//_SubsurfaceColor ("Subsurface Color", Color) = (1, 0.2, 0.2, 1)
		_SSSIntensity ("SSS Intensity", Range(0.0, 1)) = 0.2
		//_BumpBias ("Bump Map Blurring", Range(0, 5)) = 2.0
		//_DiffuseWrap ("Diffuse Wrap", Vector) = (0.75, 0.375, 0.1875, 0)
		[Space(18)]
		_LightColor("Light Color",Color)=(1,1,1,1)
		_LightIntensity("Light Intensity",Range(0,2))=1


		[Space(18)]
		_SpecRoughness  ("Specular Roughness", Range(0.01, 0.99)) = 0.15
		_SpecBrightness ("Specular Brightness", Range(0, 2)) = 0.75
		[Space(18)]
		_EnvAmbientIntensity("Enviroment Ambient Intensity",Range(0.01,2))=1
		[HideInInspector]_SHAr ("First Order Harmonic_SHAr", Vector) = (0.1410518,0.1996599,-0.1916448,0.4627451) 
		[HideInInspector]_SHAg ("First Order Harmonic_SHAg", Vector) = (0.1914412,0.3132915,-0.251553,0.5294118) 
		[HideInInspector]_SHAb ("First Order Harmonic_SHAb", Vector) = (0.2108869,0.4276009,-0.2584893,0.5372549) 

		[HideInInspector]_SHBr ("Second Order Harmonic_SHBr", Vector) = (0.04257296,-0.1443495,0.1463619,0.0) 
		[HideInInspector]_SHBg ("Second Order Harmonic_SHBg", Vector) = (0.06174606,-0.1617367,0.1746086,0.0) 
		[HideInInspector]_SHBb ("Second Order Harmonic_SHBb", Vector) = (0.07339491,-0.1538019,0.173522,0.0) 

		[HideInInspector]_SHC ("Third OrderHarmonic_SHC", Vector) = (0.06419951,0.06835041,0.05078474,1.0)



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
                
            float4  frag(v2f i):SV_Target
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
			// compile directives
			#pragma vertex vert_surf
			#pragma fragment frag_surf
			#pragma target 3.0
			#pragma multi_compile_fwdbase
			#include "HLSLSupport.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityShaderUtilities.cginc"
			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			sampler2D _SpecTex;
			sampler2D _BeckmannTex;
			sampler2D _SSSLUT;
			half _SSSIntensity;
			//half _BumpBias;
			half _SpecRoughness;
			half _SpecBrightness;
			fixed3 _SkinColor;
			uniform float4 _SHAr;
			uniform float4 _SHAg;
			uniform float4 _SHAb; 

			uniform float4 _SHBr;
			uniform float4 _SHBg;
			uniform float4 _SHBb;

			uniform float4 _SHC;
			half _EnvAmbientIntensity;
			half3 _LightColor;
			half _LightIntensity;




			float FresnelReflectance (float3 H, float3 V, float F0)
			{
				half base = 1.0 - dot(V, H);
				half exponential = pow(base, 5.0);
				return exponential + F0 * (1.0 - exponential);
			}
			float SkinSpecular(
				half3 N,     // Bumped surface normal
				half3 L,     // Points to light
				half3 V,     // Points to eye
				half m,      // Roughness
				half rho_s   // Specular brightness
			)
			{
				half ndotl = max(dot(N, L), 0);

				half3 h = L + V;          // Unnormalized half-way vector
				half3 H = normalize(h);
				half ndoth = dot(N, H);

				half PH = pow(2.0 * tex2D(_BeckmannTex, float2(ndoth, m)).x, 10.0);

				half F = FresnelReflectance(H, V, 0.028);
				half frSpec = max(PH * F / dot(h, h), 0.0);
				return ndotl * rho_s * frSpec;
			}



			half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten,UnityGI gi) 
			{
				s.Albedo=GammaToLinearSpace(s.Albedo);
				s.Specular=GammaToLinearSpace(s.Specular);
				half3 h = normalize (lightDir + viewDir);
				half diff = max (0, dot (s.Normal, lightDir));
				half specMask=s.Specular;
				half3 L = normalize(lightDir);
				half3 V = normalize(viewDir);
				half ldn = dot(L, s.Normal);
				fixed3 sss = tex2D(_SSSLUT,half2((ldn*0.5+0.5),_SSSIntensity));
				half specularWeight = SkinSpecular(s.Normal, L, V, _SpecRoughness, _SpecBrightness);
				half3 specColor = specularWeight* specMask;
				fixed3 finalColor=(sss+specColor)*_LightColor*_LightIntensity*s.Albedo/2.5*_SkinColor*atten;
				finalColor+=gi.indirect.diffuse*s.Albedo;
				//finalColor=saturate(finalColor);
				finalColor=LinearToGammaSpace(finalColor);
				return fixed4(finalColor,1);
			}

			struct Input 
			{
				float2 uv_MainTex;
			};
    
		
    
			void surf (Input IN, inout SurfaceOutput o) 
			{
			
				o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
				o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_MainTex));
				o.Specular = tex2D(_SpecTex, IN.uv_MainTex).r;
			}

			struct v2f_surf 
			{
				UNITY_POSITION(pos);
				float4 pack0 : TEXCOORD0; // _MainTex _BumpMap
				float2 pack1 : TEXCOORD1; // _Mask01Map
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				#if UNITY_SHOULD_SAMPLE_SH
					half3 sh : TEXCOORD5; // SH
				#endif
				UNITY_SHADOW_COORDS(6)
			};
		

			// vertex shader
			v2f_surf vert_surf (appdata_full v)
			{
				v2f_surf o;
				UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
				o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
				return o;
			}


			inline UnityGI MY_UnityGI_Base(UnityGIInput data, half occlusion, half3 normalWorld)
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

				//o_gi.indirect.diffuse *= occlusion;
				return o_gi;
			}







			inline void LightingCustomSpecular_GI (
				SurfaceOutput s,
				UnityGIInput data,
				inout UnityGI gi)
			{
				gi = MY_UnityGI_Base(data, 1.0, s.Normal);
			}

























			


			// fragment shader
			fixed4 frag_surf (v2f_surf IN) : SV_Target 
			{
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT(Input,surfIN);
				surfIN.uv_MainTex.x = 1.0;
				surfIN.uv_MainTex = IN.pack0.xy;
				float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				#ifdef UNITY_COMPILER_HLSL
					SurfaceOutput o = (SurfaceOutput)0;
				#else
					SurfaceOutput o;
				#endif
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Specular = 0.0;
				o.Alpha = 0.0;
				o.Gloss = 0.0;
				fixed3 normalWorldVertex = fixed3(0,0,1);
				o.Normal = fixed3(0,0,1);

				// call surface function
				surf (surfIN, o);

				// compute lighting & shadowing factor
				UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
				fixed4 c = 0;
				float3 worldN;
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
				//LightingCustomStandard_GI(o, giInput, gi);
				// realtime lighting: call lighting function

				LightingCustomSpecular_GI(o, giInput, gi);


				c += LightingSimpleSpecular (o, lightDir, worldViewDir, atten,gi);
				c.a = o.Alpha;
				UNITY_OPAQUE_ALPHA(c.a);
				return c;
			}
			ENDCG
		}
	}
	FallBack "ZJY/DDZReplaceDefault"
}
