// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ZJY/Role/Hair_Anisotropy2Pass_low" 
{
	Properties 
	{
        _MainColor ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Diffuse (RGB) Alpha (A)", 2D) = "white" {}		
        _NormalTex ("Normal Map", 2D) = "Black" {}
		_NormalScale("Normal Scale", Range(0, 10)) = 1
		_Specular ("Specular Amount", Range(0, 5)) = 1.0 
        _SpecularColor ("Specular Color1", Color) = (1,1,1,1)
		_SpecularMultiplier ("Specular Power1", float) = 100.0	
		_PrimaryShift ( "Specular Primary Shift", float) = 0.0
		_AnisoDir ("SpecShift(G),Spec Mask (B)", 2D) = "white" {}
	}
	
	SubShader
	{
		//在半透明之前渲染
		//Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		

	/*	Pass
		{
			ZWrite On
			ColorMask 0
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#pragma target 3.0

			sampler2D _MainTex, _AnisoDir,_NormalTex;
			float4 _MainTex_ST, _AnisoDir_ST,_NormalTex_ST;

			half _SpecularMultiplier, _PrimaryShift,_Specular,_SecondaryShift,_SpecularMultiplier2;
			half4 _SpecularColor, _MainColor,_SpecularColor2;

			half _Cutoff;
			half _NormalScale;
			
			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};
		
			struct v2f
			{
				half4 uv : TEXCOORD0;
				half4 vertex : SV_POSITION;
			};

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{	
				fixed4 albedo = tex2D(_MainTex, i.uv);
				clip(albedo.a - _Cutoff); //进行AlphaTest     //clip函数，但参数为负数则舍弃该片元输出
				return fixed4(0,0,0,1);
			};
			ENDCG
		}*/

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#pragma target 3.0

			sampler2D _MainTex, _AnisoDir,_NormalTex;
			half4 _MainTex_ST, _AnisoDir_ST,_NormalTex_ST;

			half _SpecularMultiplier, _PrimaryShift,_Specular;
			half4 _SpecularColor, _MainColor;

			half _Cutoff;
			half _NormalScale;
			
			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
			};
		
			struct v2f
			{
				half4 uv : TEXCOORD0;
				half2 uv_AnisoDir: TEXCOORD1;
				half4 TtoW0 : TEXCOORD2;  
				half4 TtoW1 : TEXCOORD3;  
				half4 TtoW2 : TEXCOORD4;
				half4 vertex : SV_POSITION;
				half3 SH_Light:TEXCOORD05;
			};

			//获取头发高光
			fixed StrandSpecular ( fixed3 T, fixed3 V, fixed3 L, fixed exponent)
			{
				fixed3 H = normalize(L + V);
				fixed dotTH = dot(T, H);
				fixed sinTH = sqrt(1 - dotTH * dotTH);
				fixed dirAtten = smoothstep(-1, 0, dotTH);
				return dirAtten * pow(sinTH, exponent);
			}
			
			//沿着法线方向调整Tangent方向
			fixed3 ShiftTangent ( fixed3 T, fixed3 N, fixed shift)
			{
				return normalize(T + shift * N);
			}

			v2f vert (appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f,o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);
				o.uv_AnisoDir = TRANSFORM_TEX(v.texcoord, _AnisoDir);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  

				o.SH_Light=ShadeSH9(half4(worldNormal,1));
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{	
				fixed4 albedo = tex2D(_MainTex, i.uv);
				half3 diffuseColor = albedo.rgb;
				//法线相关
				fixed3 bump = UnpackScaleNormal(tex2D(_NormalTex, i.uv.zw),_NormalScale);
				fixed3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				half3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldTangent = normalize(half3(i.TtoW0.x, i.TtoW1.x, i.TtoW2.x));
				fixed3 worldBinormal = normalize(half3(i.TtoW0.y, i.TtoW1.y, i.TtoW2.y));			
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 spec = tex2D(_AnisoDir, i.uv_AnisoDir).rgb;
				//计算切线方向的偏移度
				half shiftTex = spec.g;
				half3 t1 = ShiftTangent(worldBinormal, worldNormal, _PrimaryShift + shiftTex);
				//计算高光强度
				half3 spec1 = StrandSpecular(t1, worldViewDir, worldLightDir, _SpecularMultiplier)* _SpecularColor;
				spec1=saturate(spec1);
				fixed4 finalColor = 0;
				finalColor.rgb = diffuseColor *_LightColor0.rgb*max(0,dot(worldLightDir,worldNormal)) + spec1 * _Specular*_LightColor0.rgb;//第一层高光
				finalColor.rgb+=i.SH_Light*albedo.rgb* _MainColor.rgb;
				finalColor.a = 1;
				return finalColor;
			};
			ENDCG
		}

	}

	FallBack "Mobile/VertexLit"
}