import sys, pygame

# pygame and game state init, constants etc.
pygame.init()
size = width,height = 1280,720

pastel1 = 237,109,121
pastel2 = 218,151,224
pastel3 = 255,137,181
pastel4 = 137,140,255

bg_colors = [pastel1,pastel2,pastel3,pastel4]

screen = pygame.display.set_mode(size)

# load bitmaps

# gameloop

while 1:
	for event in pygame.event.get():
		if event.type == pygame.QUIT: sys.exit()

	screen.fill(bg_colors[int(pygame.time.get_ticks()*0.001) % len(bg_colors)])
	pygame.display.flip()
