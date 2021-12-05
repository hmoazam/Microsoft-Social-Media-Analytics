# Microsoft Social Media Analytics Accelerator

Social media analytics is an extremely popular topic as businesses, governments, event planners and others seek insights into people's comments and opinions. There is a plethora of data available from various sources such as social media posts, news articles, and more. This repository contains a proof of concept (PoC) implementation for an end-to-end social media listening and visualization system, built with the Microsoft Azure cloud. It is meant to serve as a quick-start to showcase the insights that can be derived from social media listening. It is not meant to serve as a production level solution, but a starting point towards one. We have provided some guidance for extending the solution, however it can be customized and extended in multiple different ways.

## README Sections

1. [Introduction & Scope](#introduction--scope)
2. Prerequisites
    1. Twitter Developer Account
    2. News API
    3. Azure Resource Group
    4. Azure Resource Providers
3. Solution Architecture
4. Deploying Azure Services
    1. Synapse Analytics
    2. Cosmos DB
    3. Translator
    4. Text Analytics
    5. Azure Maps
    6. Storage Account
5. Configuring the Solution (subsections todo)
6. Running the Solution
7. Visualizing with Power BI
    1. Dashboard template
    2. Publishing
8. [Cost Estimates](#cost-estimates)
9. Recommendations for Extending the Solution
    1. Streaming architecture
    2. Additional data sources
    3. Analysing images/audio
10. FAQs
11. Known Issues
12. Contact Us

## Introduction & Scope

There are a plethora of social media platforms, however this implementation connects to and analyzes data from two sources: 
- Twitter
- News Articles

However, the solution architecture and data models are such that they can be used or easily modified to include data from additional sources which you may wish to incorporate into the solution.

As this implementation is for a PoC, the implementation ingests Twitter data in bulk, which ensures we can gather a large amount of data in a short time to create a representative dashboard. However, many production implementations will require a near-real-time implementation, for which a streaming approach is more suitable. This is described in more detail in 

## Prerequisites

## Solution Architecture

## Deploying Azure Services

## Configuring the Solution

## Running the Solution

## Visualizing with Power BI

## Cost Estimates

## Recommendations for Extending the Solution

## FAQs

## Known Issues