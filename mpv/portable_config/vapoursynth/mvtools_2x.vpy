### mvtools倍帧，一般开销

import vapoursynth as vs
from vapoursynth import core
import math

input = video_in
w_in, h_in = input.width, input.height

############
# 用户选项 #
############

Recal = True
Block = True
## <True|False> 是否使用二次分析
## <True|False> 是否使用Block模式

if container_fps > 32 :
	raise Exception("源帧率超过限制的范围，已临时禁用该脚本。")

blk_size = 32
w_tmp = math.ceil(w_in / blk_size) * blk_size - w_in
h_tmp = math.ceil(h_in / blk_size) * blk_size - h_in

cut0 = core.std.AddBorders(clip=input, right=w_tmp, bottom=h_tmp)
cut1 = core.std.AssumeFPS(clip=cut0, fpsnum=int(container_fps * 1000), fpsden=1000)
cut_s = core.mv.Super(clip=cut1, pel=1, sharp=0)
cut_b = core.mv.Analyse(super=cut_s, blksize=blk_size, search=2, isb=True)
cut_f = core.mv.Analyse(super=cut_s, blksize=blk_size, search=2)

if Recal :
	cut_b = core.mv.Recalculate(super=cut_s, vectors=cut_b, thsad=200, blksize=blk_size / 2, search=2, searchparam=1)
	cut_f = core.mv.Recalculate(super=cut_s, vectors=cut_f, thsad=200, blksize=blk_size / 2, search=2, searchparam=1)
else :
	cut_b, cut_f = cut_b, cut_f

if Block :
	fin = core.mv.BlockFPS(clip=cut1, super=cut_s, mvbw=cut_b, mvfw=cut_f, num=container_fps * 2 * 1000, den=1000)
else :
	fin = core.mv.FlowFPS(clip=cut1, super=cut_s, mvbw=cut_b, mvfw=cut_f, num=container_fps * 2 * 1000, den=1000, mask=1)

output = core.std.Crop(clip=fin, right=w_tmp, bottom=h_tmp)

output.set_output()
