### 使用nnedi3算法进行两倍放大
### 追求速度应使用着色器版本，例如 ../shaders/nnedi3-nns128-win8x4.glsl

import vapoursynth as vs
from vapoursynth import core
import math

input = video_in

edi_core = 3
plug = "zimg"
pixel_size = 4
neuron_num = 3
GPU = -1
# 使用的核心 1=nnedi3 // 2=znedi3 // 3=nnedi3cl
# 使用 "zimg" （转换为yuv444最终输出）或 "fmtconv" （保持原始像素格式）进行内部格式转换
# 像素尺寸 0=8x6 // 4=8x4
# 神经元数量 0=16 // 1=32 // 2=64 // 3=128 // 4=256
# 使用OpenCL加速的设备（仅支持nnedi3cl）

if input.width > 2560 and input.height > 2560 :
	raise Warning("源分辨率超过限制的范围，已临时禁用该脚本。")

## port rpow2 from https://gist.github.com/YamashitaRen/020c497524e794779d9c

def nnedi3_rpow2(clip, rfactor, correct_shift="zimg", nsize=0, nns=3, qual=None, etype=None, pscrn=None, opt=None, int16_prescreener=None, int16_predictor=None, exp=None) :

	def edi(clip, field, dh) :
		return core.nnedi3.nnedi3(clip=clip, field=field, dh=dh, nsize=nsize, nns=nns, qual=qual, etype=etype, pscrn=pscrn, opt=opt, int16_prescreener=int16_prescreener, int16_predictor=int16_predictor, exp=exp)

	return edi_rpow2(clip=clip, rfactor=rfactor, correct_shift=correct_shift, edi=edi)

def znedi3_rpow2(clip, rfactor, correct_shift="zimg", nsize=0, nns=3, qual=None, etype=None, pscrn=None, opt=None, int16_prescreener=None, int16_predictor=None, exp=None) :

	def edi(clip, field, dh) :
		return core.znedi3.nnedi3(clip=clip, field=field, dh=dh, nsize=nsize, nns=nns, qual=qual, etype=etype, pscrn=pscrn, opt=opt, int16_prescreener=int16_prescreener, int16_predictor=int16_predictor, exp=exp)

	return edi_rpow2(clip=clip, rfactor=rfactor, correct_shift=correct_shift, edi=edi)

def nnedi3cl_rpow2(clip, rfactor, correct_shift="zimg", nsize=0, nns=3, qual=None, etype=None, pscrn=None, device=None) :

	def edi(clip, field, dh) :
		return core.nnedi3cl.NNEDI3CL(clip=clip, field=field, dh=dh, nsize=nsize, nns=nns, qual=qual, etype=etype, pscrn=pscrn, device=device)

	return edi_rpow2(clip=clip, rfactor=rfactor, correct_shift=correct_shift, edi=edi)

def edi_rpow2(clip, rfactor, correct_shift, edi) :

	steps = math.log(rfactor)/math.log(2) # 2^steps=rfactor

	if (steps).is_integer :
		steps = int(steps)
	else :
		raise ValueError('nnedi3_rpow2 : rfactor must be a power of two')

	if correct_shift not in [None,"zimg","fmtconv"] :
		raise ValueError('correct_shift must be None, "zimg" or "fmtconv" ')

	for i in range(0,2) :
		clip = core.std.Transpose(clip)
		clip = edi(clip, field=1, dh=1)
	for i in range(0,steps-1) :
		clip = core.std.Transpose(clip)
		clip = edi(clip, field=1, dh=1)
		clip = core.std.Transpose(clip)
		clip = edi(clip, field=0, dh=1)

	if correct_shift == "zimg" or correct_shift == "fmtconv" :
		clip = correct_edi_shift(clip, rfactor=rfactor, plugin=correct_shift)

	return clip

def correct_edi_shift(clip, rfactor, plugin) :

	if clip.format.subsampling_w == 1 :
		hshift = -rfactor/2+0.5 # hshift(steps+1)=2*hshift(steps)-0.5
	else :
		hshift = -0.5

	if plugin == "zimg" :
		if clip.format.subsampling_h == 0 :
			clip = core.resize.Bilinear(clip=clip, width=clip.width, height=clip.height, src_left=hshift, src_top=-0.5)
		else :
			Y = core.std.ShufflePlanes(clips=clip, planes=0, colorfamily=vs.GRAY)
			U = core.std.ShufflePlanes(clips=clip, planes=1, colorfamily=vs.GRAY)
			V = core.std.ShufflePlanes(clips=clip, planes=2, colorfamily=vs.GRAY)
			Y = core.resize.Bilinear(clip=Y, width=clip.width, height=clip.height, src_left=hshift, src_top=-0.5)
			U = core.resize.Bilinear(clip=U, width=clip.width, height=clip.height, src_left=hshift/2, src_top=-0.5)
			V = core.resize.Bilinear(clip=V, width=clip.width, height=clip.height, src_left=hshift/2, src_top=-0.5)
			clip = core.std.ShufflePlanes(clips=[Y,U,V], planes=[0,0,0], colorfamily=vs.YUV)

	if plugin == "fmtconv" :
		bits = clip.format.bits_per_sample
		if clip.format.subsampling_h == 0 :
			clip = core.fmtc.resample(clip=clip, sx=hshift, sy=-0.5)
		else :
			clip = core.fmtc.resample(clip=clip, sx=hshift, sy=-0.5, planes=[3,2,2])
			clip = core.fmtc.resample(clip=clip, sx=hshift, sy=-1, planes=[2,3,3])
		if bits != 16 :
			clip = core.fmtc.bitdepth(clip=clip, bits=bits)

	return clip

if edi_core == 1 :
	output = nnedi3_rpow2(clip=input, rfactor=2, correct_shift=plug, nsize=pixel_size, nns=neuron_num, qual=1, etype=0, pscrn=2)
if edi_core == 2 :
	output = znedi3_rpow2(clip=input, rfactor=2, correct_shift=plug, nsize=pixel_size, nns=neuron_num, qual=1, etype=0, pscrn=2)
if edi_core == 3 :
	output = nnedi3cl_rpow2(clip=input, rfactor=2, correct_shift=plug, nsize=pixel_size, nns=neuron_num, qual=1, etype=0, pscrn=2, device=GPU)

output.set_output()
