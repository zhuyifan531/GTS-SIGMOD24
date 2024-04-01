// Priority queue
// Created on 24-01-05

#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "queue.cuh"
#include "config.cuh"

typedef struct HeapStruct_k
{
	int capacity_k;
	int size_k;
	int type_k;
	BPlusNode *node[33];
	int id[33];
	float dis[33];
} PriorityQueue_k;

__device__ void initPQK(int max_size, PriorityQueue_k *pq, int type)
{
	if (max_size <= 0)
	{
		printf("max_size is illeagel!\n");
	}

	if (pq == NULL)
	{
		printf("pq is NULL!\n");
	}

	// memset(pq->eles, 0, (max_size + 1) * sizeof(Type));
	pq->capacity_k = max_size;
	pq->size_k = 0;
	pq->type_k = type;

	if (pq->type_k == 0)
	{
		for (int i = 1; i <= max_size; i++)
		{
			pq->dis[i] = -1;
		}
	}
	else
	{
		for (int i = 1; i <= max_size; i++)
		{
			pq->dis[i] = 999999;
		}
	}
}

__device__ int isEmptyPQK(PriorityQueue_k *pq)
{
	if (pq == NULL)
		return 0;
	if (pq->size_k == 0)
		return 1;
	else
		return 0;
}

__device__ int isFullPQK(PriorityQueue_k *pq)
{
	if (pq == NULL)
		return 0;
	if (pq->size_k == pq->capacity_k)
		return 1;
	else
		return 0;
}

__device__ void pushPQK(BPlusNode *node, float dis, int id, PriorityQueue_k *pq)
{
	int i = 0;

	if (isFullPQK(pq))
	{
		printf("Queue is Full!\n");
		return;
	}
	// printf("push %d\n", value);

	if (pq->type_k == 0)
	{
		for (i = pq->size_k + 1; dis > pq->dis[i / 2] && i > 1; i /= 2)
		{
			pq->dis[i] = pq->dis[i / 2];
			pq->id[i] = pq->id[i / 2];
			pq->node[i] = pq->node[i / 2];
		}
	}
	else
	{
		for (i = pq->size_k + 1; dis < pq->dis[i / 2] && i > 1; i /= 2)
		{
			pq->dis[i] = pq->dis[i / 2];
			pq->id[i] = pq->id[i / 2];
			pq->node[i] = pq->node[i / 2];
		}
	}
	pq->dis[i] = dis;
	pq->id[i] = id;
	pq->node[i] = node;

	pq->size_k++;
}

__device__ void findMaxPQK(PriorityQueue_k *pq, BPlusNode *&node, float &dis, int &id)
{
	if (isEmptyPQK(pq))
	{
		printf("Queue is empty\n");
		return;
	}
	dis = pq->dis[1];
	id = pq->id[1];
	node = pq->node[1];
}

__device__ void popPQK(PriorityQueue_k *pq, BPlusNode *&node, float &dis, int &id)
{
	int i = 1;
	int mchild = 0;

	if (isEmptyPQK(pq))
	{
		printf("Queue is empty!\n");
		return;
	}
	BPlusNode *last_node;
	float last_dis;
	int last_id;

	last_dis = pq->dis[pq->size_k];
	last_id = pq->id[pq->size_k];
	last_node = pq->node[pq->size_k];

	dis = pq->dis[1];
	id = pq->id[1];
	node = pq->node[1];

	// printf("Pop %d\n", pq->eles[1]);
	pq->size_k--;
	if (pq->size_k == 0 && pq->type_k == 0)
	{
		pq->dis[i] = -1;
	}
	else
	{
		pq->dis[i] = 999999;
	}

	if (pq->type_k == 0)
	{
		for (i = 1; i * 2 <= pq->size_k; i = mchild)
		{
			mchild = i * 2;
			if (pq->dis[mchild] < pq->dis[mchild + 1] && mchild != pq->size_k)
				mchild += 1;

			if (last_dis < pq->dis[mchild])
			{
				pq->dis[i] = pq->dis[mchild];
				pq->id[i] = pq->id[mchild];
				pq->node[i] = pq->node[mchild];
			}
			else
				break;
		}
	}
	else
	{
		for (i = 1; i * 2 <= pq->size_k; i = mchild)
		{
			mchild = i * 2;
			if (pq->dis[mchild] > pq->dis[mchild + 1] && mchild != pq->size_k)
				mchild += 1;

			if (last_dis > pq->dis[mchild])
			{
				pq->dis[i] = pq->dis[mchild];
				pq->id[i] = pq->id[mchild];
				pq->node[i] = pq->node[mchild];
			}
			else
				break;
		}
	}
	pq->dis[i] = last_dis;
	pq->id[i] = last_id;
	pq->node[i] = last_node;
}