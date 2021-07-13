import delimited "/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/build/input/ministers.csv", ///
	varnames(1) delimiter("|") encoding("utf-8") clear

gen female = .
bys name: keep if _n ==1	
br name female

/*
replace female = 0 in 1
 

replace female = 0 in 2
 

replace female = 0 in 3
 

replace female = 0 in 4
 

replace female = 0 in 5
 

replace female = 0 in 6
 

replace female = 0 in 7
 

replace female = 0 in 8
 

replace female = 0 in 9
 

replace female = 1 in 10
 

replace female = 0 in 11
 

replace female = 1 in 12
 

replace female = 0 in 13
 

replace female = 0 in 14
 

replace female = 0 in 15
 

replace female = 0 in 16
 

replace female = 1 in 17
 

replace female = 0 in 18
 

replace female = 0 in 19
 

replace female = 0 in 20
 

replace female = 1 in 21
 

replace female = 1 in 22
 

replace female = 0 in 23
 

replace female = 0 in 24
 

replace female = 0 in 25
 

replace female = 0 in 26
 

replace female = 0 in 27
 

replace female = 0 in 28
 

replace female = 0 in 29
 

replace female = 0 in 30
 

replace female = 0 in 31
 

replace female = 0 in 32
 

replace female = 1 in 33
 

replace female = 1 in 34
 

replace female = 0 in 34
 

replace female = 1 in 35
 

replace female = 0 in 36
 

replace female = 0 in 37
 

replace female = 0 in 38
 

replace female = 0 in 39
 

replace female = 1 in 40
 

replace female = 0 in 41
 

replace female = 0 in 42
 

replace female = 0 in 43
 

replace female = 0 in 44
 

replace female = 0 in 45
 

replace female = 0 in 46
 

replace female = 0 in 47
 

replace female = 0 in 48
 

replace female = 0 in 49
 

replace female = 1 in 50
 

replace female = 1 in 51
 

replace female = 0 in 52
 

replace female = 0 in 53
 

replace female = 0 in 54
 

replace female = 0 in 55
 

replace female = 0 in 56
 

replace female = 0 in 57
 

replace female = 0 in 58
 

replace female = 0 in 59
 

replace female = 0 in 60
 

replace female = 0 in 61
 

replace female = 1 in 62
 

replace female = 0 in 63
 

replace female = 1 in 64
 

replace female = 0 in 65
 

replace female = 0 in 66
 

replace female = 1 in 67
 

replace female = 0 in 68
 

replace female = 0 in 69
 

replace female = 0 in 70
 

replace female = 0 in 71
 

replace female = 0 in 72
 

replace female = 0 in 73
 

replace female = 1 in 74
 

replace female = 0 in 75
 

replace female = 0 in 76
 

replace female = 0 in 77
 

replace female = 0 in 78
 

replace female = 1 in 79
 

replace female = 0 in 80
 

replace female = 1 in 81
 

replace female = 0 in 82
 

replace female = 0 in 83
 

replace female = 0 in 84
 

replace female = 0 in 85
 

replace female = 0 in 86
 

replace female = 0 in 87
 

replace female = 0 in 88
 

replace female = 1 in 89
 

replace female = 0 in 90
 

replace female = 0 in 91
 

replace female = 0 in 92
 

replace female = 0 in 93
 

replace female = 0 in 94
 

replace female = 1 in 95
 

replace female = 0 in 96
 

replace female = 1 in 97
 

replace female = 0 in 98
 

replace female = 0 in 99
 

replace female = 0 in 100
 

replace female = 0 in 101
 

replace female = 0 in 102
 

replace female = 0 in 103
 

replace female = 0 in 104
 

replace female = 0 in 105
 

replace female = 0 in 106
 

replace female = 0 in 107
 

replace female = 0 in 108
 

replace female = 1 in 109
 

replace female = 0 in 110
 

replace female = 0 in 111
 

replace female = 0 in 112
 

replace female = 0 in 113
 

replace female = 0 in 114
 

replace female = 0 in 115
 

replace female = 0 in 116
 

replace female = 0 in 117
 

replace female = 0 in 118
 

replace female = 0 in 119
 

replace female = 1 in 120
 

replace female = 0 in 121
 

replace female = 0 in 122
 

replace female = 0 in 123
 

replace female = 1 in 124
 

replace female = 0 in 125
 

replace female = 0 in 126
 

replace female = 1 in 127
 

replace female = 0 in 128
 

replace female = 0 in 129
 

replace female = 1 in 130
 

replace female = 0 in 131
 

replace female = 0 in 132
 

replace female = 0 in 133
 

replace female = 0 in 134
 

replace female = 0 in 135
 

replace female = 0 in 136
 

replace female = 1 in 137
 

replace female = 0 in 138
 

replace female = 0 in 139
 

replace female = 0 in 140
 

replace female = 0 in 141
 

replace female = 1 in 142
 

replace female = 0 in 143
 

replace female = 0 in 144
 

replace female = 0 in 145
 

replace female = 0 in 146
 

replace female = 0 in 147
 

replace female = 0 in 148
 

replace female = 0 in 149
 

replace female = 0 in 150
 

replace female = 0 in 151
 

replace female = 0 in 152
 

replace female = 1 in 153
 

replace female = 0 in 154
 

replace female = 0 in 155
 

replace female = 0 in 156
 

replace female = 0 in 157
 

replace female = 1 in 158
 

replace female = 0 in 159
 

replace female = 0 in 160
 

replace female = 0 in 161
 

replace female = 0 in 162
 

replace female = 0 in 163
 

replace female = 0 in 164
 

replace female = 0 in 165
 

replace female = 0 in 166
 

replace female = 0 in 167
 

replace female = 0 in 168
 

replace female = 0 in 169
 

replace female = 0 in 170
 

replace female = 0 in 171
 

replace female = 0 in 172
 

replace female = 0 in 173
 

replace female = 0 in 174
 

replace female = 1 in 175
 

replace female = 0 in 176
 

replace female = 0 in 177
 

replace female = 0 in 178
 

replace female = 0 in 179
 

replace female = 0 in 180
 

replace female = 0 in 181
 

replace female = 0 in 182
 

replace female = 0 in 183
 

replace female = 0 in 184
 

replace female = 0 in 185
 

replace female = 0 in 186
 

replace female = 1 in 187
 

replace female = 0 in 188
 

replace female = 0 in 189
 

replace female = 0 in 190
 

replace female = 0 in 191
 

replace female = 0 in 192
 

replace female = 0 in 193
 

replace female = 1 in 194
 

replace female = 0 in 195
 

replace female = 0 in 196
 

replace female = 0 in 197
 

replace female = 0 in 198
 

replace female = 0 in 199
 

replace female = 1 in 200
 

replace female = 0 in 201
 

replace female = 0 in 202
 

replace female = 1 in 203
 

replace female = 0 in 204
 

replace female = 1 in 205
 

replace female = 0 in 206
 

replace female = 0 in 207
 

replace female = 0 in 208
 

replace female = 0 in 209
 

replace female = 0 in 210
 

replace female = 0 in 211
 

replace female = 0 in 212
 

replace female = 0 in 213
 

replace female = 0 in 214
 

replace female = 1 in 215
 

replace female = 0 in 216
 

replace female = 0 in 217
 

replace female = 1 in 218
 

replace female = 0 in 219
 

replace female = 0 in 220
 

replace female = 0 in 221
 

replace female = 0 in 222
 

replace female = 0 in 223
 

replace female = 0 in 224
 

replace female = 0 in 225
 

replace female = 0 in 226
 

replace female = 0 in 227
 

replace female = 0 in 228
 

replace female = 0 in 229
 

replace female = 0 in 230
 

replace female = 0 in 231
 

replace female = 0 in 232
 

replace female = 0 in 233
 

replace female = 0 in 234
 

replace female = 0 in 235
 

replace female = 0 in 236
 

replace female = 1 in 237
 

replace female = 0 in 238
 

replace female = 0 in 239
 

replace female = 0 in 240
 

replace female = 0 in 241
 

replace female = 0 in 242
 

replace female = 1 in 243
 

replace female = 0 in 244
 

replace female = 0 in 245
 

replace female = 0 in 246
 

replace female = 1 in 247
 

replace female = 1 in 248
 

replace female = 0 in 249
 

replace female = 1 in 250
 

replace female = 0 in 251
 

replace female = 0 in 252
 

replace female = 0 in 253
 

replace female = 0 in 254
 

replace female = 0 in 255
 

replace female = 0 in 256
 

replace female = 0 in 257
 

replace female = 1 in 258
 

replace female = 1 in 259
 

replace female = 0 in 260
 

replace female = 0 in 261
 

replace female = 0 in 262
 

replace female = 0 in 263
 

replace female = 0 in 264
 

replace female = 0 in 265
 

replace female = 1 in 266
 

replace female = 0 in 267
 

replace female = 0 in 268
 

replace female = 0 in 269
 

replace female = 0 in 270
 

replace female = 1 in 271
 

replace female = 0 in 272
 

replace female = 0 in 273
 

replace female = 0 in 274
 

replace female = 0 in 275
 

replace female = 0 in 276
 

replace female = 0 in 277
 

replace female = 0 in 278
 

replace female = 0 in 279
 

replace female = 0 in 280
 

replace female = 0 in 281
 

replace female = 0 in 282
 

replace female = 0 in 284
 

replace female = 0 in 283
 

replace female = 0 in 285
 

replace female = 0 in 286
 

replace female = 0 in 287
 

replace female = 1 in 288
 

replace female = 0 in 289
 

replace female = 0 in 290
 

replace female = 0 in 291
 

replace female = 1 in 292
 

replace female = 0 in 293
 

replace female = 0 in 294
 

replace female = 0 in 295
 

replace female = 0 in 296
 

replace female = 0 in 297
 

replace female = 0 in 298
 

replace female = 0 in 299
 

replace female = 0 in 300
 

replace female = 0 in 301
 

replace female = 1 in 302
 

replace female = 1 in 303
 

replace female = 0 in 304
 

replace female = 0 in 305
 

replace female = 0 in 306
 

replace female = 0 in 307
 

replace female = 0 in 308
 

replace female = 0 in 309
 

replace female = 0 in 310
 

replace female = 0 in 311
 

replace female = 0 in 312
 

replace female = 0 in 313
 

replace female = 0 in 314
 

replace female = 0 in 315
 

replace female = 0 in 316
 

replace female = 0 in 317
 

replace female = 0 in 318
 

replace female = 0 in 319
 

replace female = 0 in 320
 

replace female = 1 in 321
 

replace female = 0 in 322
 

replace female = 0 in 323
 

replace female = 0 in 324
 

replace female = 1 in 325
 

replace female = 0 in 326
 

replace female = 0 in 327
 

replace female = 0 in 328
 

replace female = 0 in 329
 

replace female = 0 in 330
 

replace female = 0 in 331
 

replace female = 0 in 332
 

replace female = 0 in 333
 

replace female = 1 in 334
 

replace female = 0 in 335
 

replace female = 0 in 336
 

replace female = 0 in 337
 

replace female = 0 in 338
 

replace female = 1 in 339
 

replace female = 1 in 340
 

replace female = 0 in 341
 

replace female = 0 in 342
 

replace female = 0 in 343
 

replace female = 0 in 344
 

replace female = 0 in 345
 

replace female = 0 in 346
 

replace female = 0 in 347
 

replace female = 0 in 348
 

replace female = 0 in 349
 

replace female = 0 in 350
 

replace female = 0 in 351
 

replace female = 0 in 352
 

replace female = 0 in 353
 

replace female = 0 in 354
 

replace female = 0 in 355
 

replace female = 0 in 356
 

replace female = 0 in 357
 

replace female = 0 in 358
 

replace female = 1 in 359
 

replace female = 0 in 360
 

replace female = 0 in 361
 

replace female = 0 in 362
 

replace female = 0 in 363
 

replace female = 0 in 364
 

replace female = 0 in 365
 

replace female = 0 in 366
 

replace female = 0 in 367
 

replace female = 0 in 368
 

replace female = 0 in 369
 

replace female = 0 in 370
 

replace female = 1 in 371
 

replace female = 0 in 372
 

replace female = 0 in 373
 

replace female = 0 in 374
 

replace female = 0 in 375
 

replace female = 0 in 376
 

replace female = 0 in 377
 

replace female = 0 in 378
 

replace female = 0 in 379
 

replace female = 0 in 380
 

replace female = 0 in 381
 

replace female = 0 in 382
 

replace female = 0 in 383
 

replace female = 0 in 384
 

replace female = 0 in 385
 

replace female = 0 in 386
 

replace female = 0 in 387
 

replace female = 1 in 388
 

replace female = 0 in 389
 

replace female = 0 in 390
 

replace female = 0 in 391
 

replace female = 1 in 392
 

replace female = 0 in 393
 

replace female = 1 in 394
 

replace female = 0 in 395
 

replace female = 1 in 396
 

replace female = 0 in 397
 

replace female = 0 in 398
 

replace female = 1 in 399
 

replace female = 0 in 400
 

replace female = 0 in 401
 

replace female = 0 in 402
 

replace female = 1 in 403
 

replace female = 0 in 404
 

replace female = 0 in 405
 

replace female = 0 in 406
 

replace female = 0 in 407
 

replace female = 0 in 408
 

replace female = 0 in 409
 

replace female = 1 in 410
 

replace female = 0 in 411
 

replace female = 0 in 412
 

replace female = 0 in 413
 

replace female = 0 in 414
 

replace female = 1 in 415
 

replace female = 0 in 416
 

replace female = 0 in 417
 

replace female = 0 in 418
 

replace female = 0 in 419
 

replace female = 0 in 420
 

replace female = 0 in 421
 

replace female = 0 in 422
 

replace female = 0 in 423
 

replace female = 1 in 424
 

replace female = 0 in 425
 

replace female = 0 in 426
 

replace female = 1 in 427
 

replace female = 0 in 428
 

replace female = 0 in 429
 

replace female = 0 in 430
 

replace female = 0 in 431
 

replace female = 0 in 432
 

replace female = 0 in 433
 

replace female = 0 in 434
 

replace female = 0 in 435
 

replace female = 0 in 436
 

replace female = 1 in 437
 

replace female = 0 in 438
 

replace female = 0 in 439
 

replace female = 1 in 440
 

replace female = 0 in 441
 

replace female = 0 in 442
 

replace female = 0 in 443
 

replace female = 0 in 444
 

replace female = 1 in 445
 

replace female = 1 in 446
 

replace female = 0 in 447
 

replace female = 1 in 448
 

replace female = 1 in 449
 

replace female = 0 in 450
 

replace female = 1 in 451
 

replace female = 0 in 452
 

replace female = 0 in 453
 

replace female = 0 in 454
 

replace female = 0 in 455
 

replace female = 0 in 456
 

replace female = 0 in 457
 

replace female = 0 in 458
 

replace female = 0 in 459
 

replace female = 0 in 460
 

replace female = 0 in 461
 

replace female = 0 in 462
 

replace female = 0 in 463
 

replace female = 0 in 464
 

replace female = 0 in 465
 

replace female = 0 in 466
 

replace female = 1 in 466
 

replace female = 0 in 467
 

replace female = 0 in 468
 

replace female = 0 in 469
 

replace female = 0 in 470
 

replace female = 0 in 471
 

replace female = 0 in 472
 

replace female = 0 in 473
 

replace female = 0 in 474
 

replace female = 0 in 475
 

replace female = 1 in 476
 

replace female = 1 in 477
 

replace female = 0 in 478
 

replace female = 1 in 479
 

replace female = 1 in 480
 

replace female = 0 in 481
 

replace female = 0 in 482
 

replace female = 0 in 483
 

replace female = 0 in 484
 

replace female = 0 in 485
 

replace female = 0 in 486
 

replace female = 0 in 487
 

replace female = 0 in 488
 

replace female = 0 in 489
 

replace female = 0 in 490
 

replace female = 0 in 491
 

replace female = 0 in 492
 

replace female = 0 in 493
 

replace female = 0 in 494
 

replace female = 0 in 495
 

replace female = 0 in 496
 

replace female = 0 in 497
 

replace female = 0 in 498
 

replace female = 1 in 499
 

replace female = 0 in 500
 

replace female = 0 in 501
 

replace female = 0 in 502
 

replace female = 0 in 503
 

replace female = 0 in 504
 

replace female = 1 in 505
 

replace female = 0 in 506
 

replace female = 0 in 507
 

replace female = 0 in 508
 

replace female = 0 in 509
 

replace female = 0 in 510
 

replace female = 0 in 511
 

replace female = 0 in 512
 

replace female = 0 in 513
 

replace female = 1 in 514
 

replace female = 1 in 515
 

replace female = 0 in 516
 

replace female = 0 in 517
 

replace female = 0 in 518
 

replace female = 0 in 519
 

replace female = 0 in 520
 

replace female = 0 in 521
 

replace female = 0 in 522
 

replace female = 0 in 523
 

replace female = 0 in 524
 

replace female = 0 in 525
 

replace female = 0 in 526
 

replace female = 0 in 527
 

replace female = 1 in 528
 

replace female = 0 in 529
 

replace female = 1 in 530
 

replace female = 0 in 531
 

replace female = 0 in 532
 

replace female = 0 in 533
 

replace female = 0 in 534
 

replace female = 1 in 535
 

replace female = 1 in 536
 

replace female = 0 in 537
 

replace female = 0 in 538
 

replace female = 0 in 539
 

replace female = 0 in 540
 

replace female = 0 in 541
 

replace female = 0 in 542
 

replace female = 0 in 543
 

replace female = 0 in 544
 

replace female = 1 in 545
 

replace female = 0 in 546
 

replace female = 1 in 547
 

replace female = 0 in 548
 

replace female = 0 in 549
 

replace female = 0 in 550
 

replace female = 0 in 551
 

replace female = 1 in 552
 

replace female = 0 in 553
 

replace female = 1 in 554
 

replace female = 0 in 555
 

replace female = 0 in 556
 

replace female = 0 in 557
 

replace female = 0 in 558
 

replace female = 0 in 559
 

replace female = 0 in 560
 

replace female = 0 in 561
 

replace female = 1 in 562
 

replace female = 0 in 563
 

replace female = 0 in 564
 

replace female = 0 in 565
 

replace female = 0 in 566
 

replace female = 0 in 567
 

replace female = 0 in 568
 

replace female = 0 in 569
 

replace female = 1 in 570
 

replace female = 0 in 571
 

replace female = 0 in 572
 

replace female = 0 in 573
 

replace female = 1 in 574
 

replace female = 0 in 575
 

replace female = 1 in 576
 

replace female = 0 in 577
 

replace female = 0 in 578
 

replace female = 0 in 579
 

replace female = 0 in 580
 

replace female = 0 in 581
 

replace female = 0 in 582
 

replace female = 0 in 583
 

replace female = 0 in 584
 

replace female = 0 in 585
 

replace female = 1 in 585
 

replace female = 0 in 586
 

replace female = 0 in 587
 

replace female = 0 in 588
 

replace female = 0 in 589
 

replace female = 0 in 590
 

replace female = 0 in 591
 

replace female = 0 in 592
 

replace female = 1 in 593
 

replace female = 0 in 594
 

replace female = 0 in 595
 

replace female = 0 in 596
 

replace female = 0 in 597
 

replace female = 0 in 598
 

replace female = 0 in 599
 

replace female = 0 in 600
 

replace female = 0 in 601
 

replace female = 0 in 602
 

replace female = 0 in 603
 

replace female = 0 in 604
 

replace female = 0 in 605
 

replace female = 0 in 606
 

replace female = 0 in 607

keep name female


outsheet using "/Users/Salla/Dropbox (Aalto)/speech-polatization/code/remote/parliamentary-speech/build/input/minister-gender.csv", ///
	delimiter("|")

