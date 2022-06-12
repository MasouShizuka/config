### rife v4 倍帧，默认以质量交换性能

import vapoursynth as vs
from vapoursynth import core

input = video_in
colorlv = input.get_frame(0).props._ColorRange
pix_fmt = input.format.id

max_Leng = 720
scene_th = 0.1
frame_multi = 2
GPU = 0
GPU_t = 2
static_th = 60.0
pix_fmt2 = vs.YUV444P8
# 若视频的短边超过该长度将被强制降采样，高端显卡的推荐值范围 1080 -- 720
# 场景切换的检测阈值，初始设置保守，设置为 0.2 可获得更明显的效果但引入更多瑕疵
# 帧率倍数（可用浮点；只支持 v4 模型）
# 使用的显卡序号，0为排序一号
# 使用的显卡线程数
# 静止帧的检测阈值，不对该类帧进行补偿计算
# 输出像素格式（使用色度半采样格式时，须确保预降采样后的双边长度为偶数） vs.YUV420P8（最优化性能） // pix_fmt（同源） // vs.YUV444P16（最小化精度损失）

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
cut2 = core.rife.RIFE(clip=cut1, model=9, multiplier=frame_multi, gpu_id=GPU, gpu_thread=GPU_t, sc=True, skip=True, skip_threshold=static_th)

output = cut2.resize.Bilinear(format=pix_fmt2, matrix_s="709", range=1 if colorlv==0 else None)

output.set_output()
