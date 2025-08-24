// 文档 https://github.com/hooke007/MPV_lazy/wiki/4_GLSL

/*

LICENSE:
  --- RAW ver.
  https://github.com/SnapdragonStudios/snapdragon-gsr/blob/main/LICENSE

*/


//!PARAM STR
//!TYPE float
//!MINIMUM 0.0
//!MAXIMUM 16.0
4.0

//!PARAM ET
//!TYPE float
//!MINIMUM 0.0
//!MAXIMUM 16.0
4.0


//!HOOK POSTKERNEL
//!BIND HOOKED
//!BIND PREKERNEL
//!DESC [QCOM_SGEDS_ms_RT]
//!WHEN HOOKED.w PREKERNEL.w > HOOKED.h PREKERNEL.h > * STR *

#define UseEdgeDirection 1

float fastLanczos2(float x)
{
	float wA = x-4.0;
	float wB = x*wA-wA;
	wA *= wA;
	return wB*wA;
}

#if (UseEdgeDirection == 1)
vec2 weightY(float dx, float dy, float c, vec3 data)
#else
vec2 weightY(float dx, float dy, float c, float data)
#endif

{
#if (UseEdgeDirection == 1)
	float std = data.x;
	vec2 dir = data.yz;

	float edgeDis = ((dx*dir.y)+(dy*dir.x));
	float x = (((dx*dx)+(dy*dy))+((edgeDis*edgeDis)*((clamp(((c*c)*std),0.0,1.0)*0.7)+-1.0)));
#else
	float std = data;
	float x = ((dx*dx)+(dy* dy))* 0.55 + clamp(abs(c)*std, 0.0, 1.0);
#endif

	float w = fastLanczos2(x);
	return vec2(w, w * c);
}

vec2 edgeDirection(vec4 left, vec4 right)
{
	vec2 dir;
	float RxLz = (right.x + (-left.z));
	float RwLy = (right.w + (-left.y));
	vec2 delta;
	delta.x = (RxLz + RwLy);
	delta.y = (RxLz + (-RwLy));
	float lengthInv = inversesqrt((delta.x * delta.x+ 3.075740e-05) + (delta.y * delta.y));
	dir.x = (delta.x * lengthInv);
	dir.y = (delta.y * lengthInv);
	return dir;
}

vec4 hook()
{

	vec4 color = HOOKED_texOff(vec2(0.0));

	vec2 imgCoord = (HOOKED_pos * PREKERNEL_size) + vec2(-0.5, 0.5);
	vec2 imgCoordPixel = floor(imgCoord);
	vec2 gather_coord = imgCoordPixel * PREKERNEL_pt;
	vec2 pl = fract(imgCoord);

	vec4 left = PREKERNEL_gather(gather_coord, 1);

	float edgeVote = abs(left.z - left.y) + abs(color.g - left.y) + abs(color.g - left.z);

	if(edgeVote > (ET / 255.0))
	{
		gather_coord.x += PREKERNEL_pt.x;

		vec4 right = PREKERNEL_gather(gather_coord + vec2(PREKERNEL_pt.x, 0.0), 1);
		vec4 upDown;
		upDown.xy = PREKERNEL_gather(gather_coord + vec2(0.0, -PREKERNEL_pt.y), 1).wz;
		upDown.zw = PREKERNEL_gather(gather_coord + vec2(0.0, PREKERNEL_pt.y), 1).yx;

		float mean = (left.y+left.z+right.x+right.w)*0.25;

		left = left - vec4(mean);
		right = right - vec4(mean);
		upDown = upDown - vec4(mean);
		color.w = color.g - mean;

		float sum = (((((abs(left.x)+abs(left.y))+abs(left.z))+abs(left.w))+(((abs(right.x)+abs(right.y))+abs(right.z))+abs(right.w)))+(((abs(upDown.x)+abs(upDown.y))+abs(upDown.z))+abs(upDown.w)));
		float sumMean = 1.014185e+01 / sum;
		float std = (sumMean*sumMean);

#if (UseEdgeDirection == 1)
		vec3 data = vec3(std, edgeDirection(left, right));
#else
		float data = std;
#endif
		vec2 aWY = weightY(pl.x, pl.y+1.0, upDown.x, data);
		aWY += weightY(pl.x-1.0, pl.y+1.0, upDown.y, data);
		aWY += weightY(pl.x-1.0, pl.y-2.0, upDown.z, data);
		aWY += weightY(pl.x, pl.y-2.0, upDown.w, data);
		aWY += weightY(pl.x+1.0, pl.y-1.0, left.x, data);
		aWY += weightY(pl.x, pl.y-1.0, left.y, data);
		aWY += weightY(pl.x, pl.y, left.z, data);
		aWY += weightY(pl.x+1.0, pl.y, left.w, data);
		aWY += weightY(pl.x-1.0, pl.y-1.0, right.x, data);
		aWY += weightY(pl.x-2.0, pl.y-1.0, right.y, data);
		aWY += weightY(pl.x-2.0, pl.y, right.z, data);
		aWY += weightY(pl.x-1.0, pl.y, right.w, data);

		float finalY = aWY.y/aWY.x;
		float maxY = max(max(left.y,left.z),max(right.x,right.w));
		float minY = min(min(left.y,left.z),min(right.x,right.w));
		float deltaY = clamp(STR*finalY, minY, maxY) - color.w;

		deltaY = clamp(deltaY, -23.0 / 255.0, 23.0 / 255.0);

		color.r = clamp((color.r+deltaY),0.0,1.0);
		color.g = clamp((color.g+deltaY),0.0,1.0);
		color.b = clamp((color.b+deltaY),0.0,1.0);
	}

	color.a = 1.0;
	return color;

}

