# Имя проекта
#-------------------------------------------------------------------------------
TARGET  = template

# Инструменты
#-------------------------------------------------------------------------------
AS := /home/egor/arm-tools/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-gcc
CC := /home/egor/arm-tools/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-gcc
LD := /home/egor/arm-tools/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-gcc
CP := /home/egor/arm-tools/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-objcopy
SZ := /home/egor/arm-tools/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-size
RM := rm -f

# Пути к CMSIS, FreeRTOS
#-------------------------------------------------------------------------------
CMSIS_PATH = ./CMSIS
FREERTOS_PATH = ./freertos

# startup файл
#-------------------------------------------------------------------------------
STARTUP = $(CMSIS_PATH)/startup_stm32f10x_md.s

# Пути поиска исходных файлов
#-------------------------------------------------------------------------------
SOURCEDIRS := src
SOURCEDIRS += $(CMSIS_PATH)/src
SOURCEDIRS += $(FREERTOS_PATH)/src

# Пути поиска хидеров
#-------------------------------------------------------------------------------
INCLUDES += include
INCLUDES += $(CMSIS_PATH)/include 
INCLUDES += $(FREERTOS_PATH)/include 

# Настройки компилятора
#-------------------------------------------------------------------------------
CFLAGS += -mthumb -mcpu=cortex-m3 # архитектура и система комманд
CFLAGS += -std=gnu99              # стандарт языка С
CFLAGS += -Wall -pedantic         # Выводить все предупреждения
CFLAGS += -Os                     # Оптимизация
#CFLAGS += -ggdb                   # Генерировать отладочную информацию для gdb
#CFLAGS += -fno-builtin

CFLAGS += $(addprefix -I, $(INCLUDES))

# Скрипт линкера
#-------------------------------------------------------------------------------
LDSCR_PATH = $(CMSIS_PATH)
LDSCRIPT   = STM32F103XB_FLASH.ld

# Настройки линкера
#-------------------------------------------------------------------------------
LDFLAGS += -nostartfiles
LDFLAGS += -T$(LDSCR_PATH)/$(LDSCRIPT)

# Настройки ассемблера
#-------------------------------------------------------------------------------
#AFLAGS += -ahls -mapcs-32

# Список объектных файлов
#-------------------------------------------------------------------------------
OBJS += $(patsubst %.c, %.o, $(wildcard  $(addsuffix /*.c, $(SOURCEDIRS))))
OBJS += $(patsubst %.s, %.o, $(STARTUP))

# Список файлов к удалению командой "make clean"
#-------------------------------------------------------------------------------
TOREMOVE += *.elf *.hex
TOREMOVE += $(addsuffix /*.o, $(SOURCEDIRS))
TOREMOVE += $(addsuffix /*.d, $(SOURCEDIRS))
TOREMOVE += $(patsubst %.s, %.o, $(STARTUP))
TOREMOVE += $(TARGET)

# Собрать все
#-------------------------------------------------------------------------------
all: $(TARGET).hex size 

# Очистка
#-------------------------------------------------------------------------------
clean:
	@$(RM) -f $(TOREMOVE)  

# Создание .hex файла
#-------------------------------------------------------------------------------
$(TARGET).hex: $(TARGET).elf
	@$(CP) -Oihex $(TARGET).elf $(TARGET).hex
        
# Показываем размер
#-------------------------------------------------------------------------------
size:
	@echo "---------------------------------------------------"
	@$(SZ) $(TARGET).elf

# Линковка
#------------------------------------------------------------------------------- 
$(TARGET).elf: $(OBJS)
	@$(LD) $(LDFLAGS) $^ -o $@

# Компиляция
#------------------------------------------------------------------------------- 
%.o: %.c
	@$(CC) $(CFLAGS) -MD -c $< -o $@
        
%.o: %.s
	@$(AS) $(CFLAGS) -c $< -o $@

# Сгенерированные gcc зависимости
#-------------------------------------------------------------------------------
include $(wildcart *.d)