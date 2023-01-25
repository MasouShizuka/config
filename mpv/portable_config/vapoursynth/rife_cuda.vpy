### rife v4 补帧，性能要求较高，N卡专用

import vapoursynth as vs
from vapoursynth import core
import math
from vsmlrt import RIFE, RIFEModel, BackendV2

input = video_in
w_in, h_in = input.width, input.height
size_in = w_in * h_in
colorlv = input.get_frame(0).props._ColorRange
fmt_in = input.format.id

############
# 用户选项 #
############

Lt_D2K = False
FPS_num = 2
GPU = 0
GPU_t = 2
St_eng = False
WS_size = 0
Lk_fmt = False
## 是否对超过DCI2K分辨率的源进行补帧
## 补帧倍率（整数）
## 使用的显卡序号，0为排序一号
## 使用的显卡线程数
## 是否使用静态引擎（需要对不同分辨率的源各进行预处理）；动态引擎自适应不同分辨率（QVGA→DCI4K）
## 约束显存（MiB），静态引擎的最小值为128（动态引擎自动双倍），设为低于此数的值即最大化利用
## 锁定输出像素格式为yuv420p8

if container_fps > 32 :
	raise Exception("源帧率超过限制的范围，已临时禁用该脚本。")
if (not Lt_D2K and (size_in > 2048 * 1088)) or (size_in  > 4096 * 2176) :
	raise Exception("源分辨率超过限制的范围，已临时禁用该脚本。")
if not St_eng and (((w_in > 4096) or (h_in > 2176)) or ((w_in < 289) or (h_in < 225))) :
	raise Exception("源分辨率不属于动态引擎支持的范围，已临时禁用该脚本。")

fmt_out = fmt_in
if fmt_in not in [vs.YUV410P8, vs.YUV411P8, vs.YUV420P8, vs.YUV422P8, vs.YUV444P8, vs.YUV420P10, vs.YUV422P10, vs.YUV444P10] :
	fmt_out = vs.YUV420P10

scale_model = 1
if Lt_D2K and St_eng and (size_in > 2048 * 1088) :
	scale_model = 0.5

tile_size = 32 / scale_model
w_tmp = math.ceil(w_in / tile_size) * tile_size - w_in
h_tmp = math.ceil(h_in / tile_size) * tile_size - h_in

cut0 = core.misc.SCDetect(clip=input, threshold=0.15)

cut1 = core.resize.Bilinear(clip=cut0, format=vs.RGBH, matrix_in_s="709")
cut2 = core.std.AddBorders(clip=cut1, right=w_tmp, bottom=h_tmp)
cut3 = RIFE(clip=cut2, multi=FPS_num, scale=scale_model, model=RIFEModel.v4_6, backend=BackendV2.TRT(
	num_streams=GPU_t, force_fp16=True, output_format=1,
	workspace=None if WS_size < 128 else (WS_size if St_eng else WS_size * 2), use_cuda_graph=True,
	static_shape=St_eng, min_shapes=[0, 0] if St_eng else [320, 256],
	opt_shapes=None if St_eng else [1920, 1088], max_shapes=None if St_eng else ([4096, 2176] if Lt_D2K else [2048, 1088]),
	use_cublas=False, use_cudnn=False, device_id=GPU))
fin = core.std.Crop(clip=cut3, right=w_tmp, bottom=h_tmp)

output = core.resize.Bilinear(clip=fin, format=vs.YUV420P8 if Lk_fmt else fmt_out, matrix_s="709", range=1 if colorlv==0 else None)
output.set_output()
