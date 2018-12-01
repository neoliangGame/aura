/* by neoliang */

#include "UnityCG.cginc"

//structions
struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;
};
struct v2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;
};
struct v2f_four
{
	float2 uv : TEXCOORD0;
	float4 uv01 : TEXCOORD1;
	float4 uv23 : TEXCOORD2;
	float4 uv45 : TEXCOORD3;
	float4 vertex : SV_POSITION;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_TexelSize;

float4 _OffSets;//offsets and strength

float thresholdA;//alpha threshold
float widthA;//edge width

float4 auraColor;//the color of whole aura

sampler2D _MaskTex;//limit the blur
float4 _MaskTex_ST;
float4 _MaskTex_TexelSize;

float enhanceA;//just enhance the alpha

sampler2D _AddTex;//overlap two pictures
float4 _AddTex_ST;
float4 _AddTex_TexelSize;


//vertex functions
v2f vert_min(appdata v)
{
	v2f o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;
	return o;
}

v2f_four vert_blur(appdata v)
{
	v2f_four o;
	o.vertex = UnityObjectToClipPos(v.vertex);
	o.uv = v.uv;// TRANSFORM_TEX(v.uv, _MainTex);

	_OffSets *= _MainTex_TexelSize.xyxy;

	o.uv01 = v.uv.xyxy + float4(1, 1, -1, -1) * _OffSets;
	o.uv23 = v.uv.xyxy + float4(1, 1, -1, -1) * _OffSets * 2.0;
	o.uv45 = v.uv.xyxy + float4(1, 1, -1, -1) * _OffSets * 3.0;

	return o;
}

//0.blur
fixed4 frag_blur(v2f_four i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);//0.4

	fixed4 col10 = tex2D(_MainTex, i.uv01.xy);//0.3
	fixed4 col11 = tex2D(_MainTex, i.uv01.zw);

	fixed4 col20 = tex2D(_MainTex, i.uv23.xy);//0.2
	fixed4 col21 = tex2D(_MainTex, i.uv23.zw);

	fixed4 col30 = tex2D(_MainTex, i.uv45.xy);//0.1
	fixed4 col31 = tex2D(_MainTex, i.uv45.zw);

	fixed4 finalColor = col * 0.4;

	finalColor += col10 * 0.15;
	finalColor += col11 * 0.15;

	finalColor += col20 * 0.1;
	finalColor += col21 * 0.1;

	finalColor += col30 * 0.05;
	finalColor += col31 * 0.05;
	return finalColor;
}

//1.edge extraction
fixed4 frag_edgeExtraction(v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);

	float diffA = abs(col.a - thresholdA);
	fixed4 finalColor = fixed4(0,0,0,0);
	if (widthA - diffA > 0) {
		finalColor = auraColor;
	}
	return finalColor;
}

//2.inner extraction
fixed4 frag_innerExtraction(v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	fixed4 finalColor = fixed4(0, 0, 0, 0);
	if (col.a - thresholdA + widthA > 0) {
		finalColor = auraColor;
	}
	return finalColor;
}

//3.inner blur
fixed4 frag_innerBlur(v2f_four i) : SV_Target
{
	fixed4 finalColor = fixed4(0,0,0,0);

	fixed4 maskColor = tex2D(_MaskTex, i.uv);
	if (maskColor.a - 0.5 > 0) {
		fixed4 col = tex2D(_MainTex, i.uv);//4

		fixed4 col10 = tex2D(_MainTex, i.uv01.xy);
		fixed4 col11 = tex2D(_MainTex, i.uv01.zw);

		fixed4 col20 = tex2D(_MainTex, i.uv23.xy);
		fixed4 col21 = tex2D(_MainTex, i.uv23.zw);

		fixed4 col30 = tex2D(_MainTex, i.uv45.xy);
		fixed4 col31 = tex2D(_MainTex, i.uv45.zw);

		float finalA = col.a * 0.4;

		finalA += col10.a * 0.15;
		finalA += col11.a * 0.15;

		finalA += col20.a * 0.1;
		finalA += col21.a * 0.1;

		finalA += col30.a * 0.05;
		finalA += col31.a * 0.05;

		finalColor = fixed4(auraColor.xyz, finalA);
	}
	return finalColor;
}

//4.enhance
fixed4 frag_enhance(v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	col.a *= enhanceA;
	return col;
}

//5.overlap
fixed4 frag_overlap(v2f i) : SV_Target
{
	fixed4 col = tex2D(_MainTex, i.uv);
	fixed4 acol = tex2D(_AddTex, i.uv);
	fixed4 finalColor = col * (1 - acol.a) + (acol.a * acol);
	return finalColor;
}