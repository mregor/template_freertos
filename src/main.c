#include "stm32f10x.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "main.h"

int main(void)
{
	GPIO_Init();
	xTaskCreate(tLED_Blink, "LED_BLINK", 32, NULL, 1, NULL);
	vTaskStartScheduler();

    while (1){}
	return 1;
}

int GPIO_Init(void)
{
	RCC->APB2ENR |= RCC_APB2ENR_IOPCEN; //Включаем порт C
    GPIOC->CRH |= GPIO_CRH_MODE13_0;
	return 1;
}

void tLED_Blink (void *argument)
{
	while (1)
	{
		GPIOC->BSRR |= GPIO_BSRR_BS13;
		vTaskDelay(500);
	    GPIOC->BSRR |= GPIO_BSRR_BR13;
		vTaskDelay(500);
	}
}
