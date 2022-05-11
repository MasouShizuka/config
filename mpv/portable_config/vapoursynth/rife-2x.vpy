### rife v4 倍帧，默认以质量交换性能

import vapoursynth as vs
from vapoursynth import core

input = video_in

max_Leng = 720
scene_th = 0.1
GPU = 0
GPU_t = 2
# 若视频的短边超过该长度将被强制降采样，高端显卡的推荐值范围 1080 -- 720 （如果对你的显卡非常自信，可以尝试把该值提高到 2160）
# 场景切换的检测阈值，初始设置保守，设置为 0.2 可获得更明显的效果但引入更多瑕疵
# 使用的显卡序号，0为排序一号
# 使用的显卡线程数

if container_fps > 32 :
	raise Warning("源帧率超过限制的范围，已临时禁用该脚本。")

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

cut0 = core.misc.SCDetect(clip=input, threshold=scene_th)

if short_edge > max_Leng :
	cut1 = cut0.resize.Bicubic(width=w_ds, height=h_ds, format=vs.RGBS, matrix_in_s="709")
else :
	cut1 = cut0.resize.Bilinear(format=vs.RGBS, matrix_in_s="709")
cut2 = core.rife.RIFE(clip=cut1, model=9, multiplier=2, gpu_id=GPU, gpu_thread=GPU_t, tta=False, uhd=False, sc=True)

output = cut2.resize.Bilinear(format=vs.YUV444P16, matrix_s="709")
if input.get_frame(0).props._ColorRange == 0 :
	output = output.resize.Bilinear(range=1)

output.set_output()
