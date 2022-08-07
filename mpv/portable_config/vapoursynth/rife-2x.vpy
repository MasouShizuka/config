### rife v4 补帧，性能要求非常高

import vapoursynth as vs
from vapoursynth import core

input = video_in
colorlv = input.get_frame(0).props._ColorRange
pix_fmt = input.format.id

max_Leng = 720
scene_th = 0.1
FPS_num = 2
FPS_den = 1
GPU = 0
GPU_t = 2
static_th = 60.0
fmt_out = pix_fmt
# 若视频的短边超过该长度将被强制降采样，以画质交换性能
# 场景切换的检测阈值，初始设置保守，设置为 0.2 可获得更明显的效果但引入更多瑕疵
# FPS_num/FPS_den 的值即帧率倍数（分子分母必须为整数，计算结果可为浮点；只支持 v4 模型）
# .
# 使用的显卡序号，0为排序一号
# 使用的显卡线程数
# 静止帧的检测阈值，不对该类帧进行补偿计算
# 输出像素格式 vs.YUV420P8（最优化性能） // pix_fmt（同源） // vs.YUV444P16（最小化精度损失）

if container_fps > 32 :
	raise Exception("源帧率超过限制的范围，已临时禁用该脚本。")

if input.width >= input.height :
	short_edge = input.height
	max_Leng2 = input.width*(max_Leng/input.height)
	w_ds = max_Leng2
	h_ds = max_Leng
else :
	short_edge = input.width
	max_Leng2 = input.height*(max_Leng/input.width)
	w_ds = max_Leng
	h_ds = max_Leng2

fmt_subsample = [vs.YUV420P8, vs.YUV422P8, vs.YUV420P10, vs.YUV422P10, vs.YUV420P16, vs.YUV422P16]
for fmt_out in fmt_subsample :
	if not (w_ds % 2 == 0) or not (h_ds % 2 == 0) :
		raise vs.Error("输出色度半采样时，裁剪后的长边和短边必须为偶数。")

cut0 = core.misc.SCDetect(clip=input, threshold=scene_th)

if short_edge > max_Leng :
	cut1 = cut0.resize.Bicubic(width=w_ds, height=h_ds, format=vs.RGBS, matrix_in_s="709")
else :
	cut1 = cut0.resize.Bilinear(format=vs.RGBS, matrix_in_s="709")
cut2 = core.rife.RIFE(clip=cut1, model=9, factor_num=FPS_num, factor_den=FPS_den, gpu_id=GPU, gpu_thread=GPU_t, sc=True, skip=True, skip_threshold=static_th)

output = cut2.resize.Bilinear(format=fmt_out, matrix_s="709", range=1 if colorlv==0 else None)

output.set_output()
