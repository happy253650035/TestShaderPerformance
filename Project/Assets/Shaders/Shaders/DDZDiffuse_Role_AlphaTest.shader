Shader "ZJY/Role/DDZDiffuse_Role_AlphaTest"
{
	Properties
	{
		_Tint("Tint Color", Color) = (1,1,1,1)
		_MainTex("Base 2D", 2D) = "white"{}
		_BumpMap("Normal Map",2D)="white"{}
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	}		
	SubShader
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			//Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			fixed4 _Tint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			fixed _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
		
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				half3 worldTangent:TEXCOORD01;
				half3 worldBinormal:TEXCOORD02;
				half3 worldLightDir:TEXCOORD3;
				fixed3 SH_Light:TEXCOORD4;
				float4 uv : TEXCOORD5;
			};
 
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldTangent=UnityObjectToWorldDir(v.tangent.xyz); 
				o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w; 
				o.worldLightDir=WorldSpaceLightDir(v.vertex);
				o.SH_Light=ShadeSH9(float4(normalize(o.worldNormal),1));
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				return o;
			}
 
			fixed4 frag(v2f i) : SV_Target
			{
				half3x3 tangentToWorld = half3x3(i.worldTangent.x, i.worldBinormal.x, i.worldNormal.x,
				 i.worldTangent.y, i.worldBinormal.y, i.worldNormal.y,
			 	 i.worldTangent.z, i.worldBinormal.z, i.worldNormal.z
				);
				fixed3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				bump=normalize( mul(tangentToWorld,bump));

				fixed3 worldNormal = normalize(i.worldNormal);
				
				fixed3 lambert = saturate(dot(bump, normalize(i.worldLightDir)));
				fixed4 color = tex2D(_MainTex, i.uv);
				fixed3 diffuse = (i.SH_Light+lambert*_LightColor0.xyz)*color.rgb;
				clip(color.a - _Cutoff); 
				return fixed4(diffuse, 1.0)*_Tint;
			}
			ENDCG
		}
	}
	Fallback "ZJY/DDZReplaceDefault"
}