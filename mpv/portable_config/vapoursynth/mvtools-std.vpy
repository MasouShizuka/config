### MOD of https://gist.github.com/KCCat/1b3a7b7f085a066af3719859f88ded02
### 中等消耗。mvtools的偏保守型补帧策略，目标约60帧

import vapoursynth as vs
from vapoursynth import core

input = video_in

dfps = 60 * 1000
# 设置 dfps 到你的目标帧率，示例即约60fps。特殊值比如 display_fps/2*1000 即目标为显示器刷新率的一半帧率，填 container_fps*2*1000 即倍帧
# 越高的帧率增加耗能，产生更多伪影，通常是不必要的。例如对于144hz的显示器来说，最多只需要补到72fps，剩下的可让mpv.conf中的 --interpolation 平滑过渡到144fps

if container_fps > 32 :
	raise Warning("源帧率超过限制的范围，已临时禁用该脚本。")

def ffps(fps) :
	rfps = int('%.0f' % fps)
	if ( abs(fps - (rfps/1.001)) < abs(fps - (rfps/1.000)) ) :
		vfps, vden = rfps*1000, 1001
	else :
		vfps, vden = rfps*1000, 1000
	return vfps, vden

vfps, vden = ffps(container_fps)
cut1 = core.std.AssumeFPS(input, fpsnum=int(vfps), fpsden=vden)
cut_s = core.mv.Super(clip=cut1, sharp=1, rfilter=4)
cut_b = core.mv.Analyse(super=cut_s, blksize=64, searchparam=0, pelsearch=3, isb=True, _lambda=0, lsad=10000, overlapv=16, badrange=0, search_coarse=4)
cut_f = core.mv.Analyse(super=cut_s, blksize=64, searchparam=0, pelsearch=3, _lambda=0, lsad=10000, overlapv=16, badrange=0, search_coarse=4)
output = core.mv.BlockFPS(clip=cut1, super=cut_s, mvbw=cut_b, mvfw=cut_f, num=dfps, den=vden, mode=2, thscd1=970, thscd2=255, blend=False)

output.set_output()
