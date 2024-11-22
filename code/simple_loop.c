#define ENABLE_VECTORIZATION 0

#if ENABLE_VECTORIZATION
#define VECTORIZABLE_LOOP \
    _Pragma("clang loop vectorize(enable) interleave(enable) vectorize_predicate(disable)")
#else
#define VECTORIZABLE_LOOP \
    _Pragma("clang loop vectorize(disable) interleave(disable)")
#endif

// void simple_loop(const int N, float *__restrict x, const float *__restrict y, const float *__restrict z) {
//     VECTORIZABLE_LOOP
//     for (int i = 0; i < N; i++) {
//         x[i] = y[i] + z[i];
//     }
// }

void inner_loop_conditional(const int N, float* x, const float* y, const int* z) {
    for (int i = 0; i < N; i++) {
        if (z[i]) {
            x[i] += y[i];
        }
    }
}

// int simple_loop_early_exit(int *A, const int Length) {
//     VECTORIZABLE_LOOP
//     for (int i = 0; i < Length; i++) {
//         if (A[i] > 10.0) goto end;
//         A[i] = 0;
//     }
// end:
//     return 0;
// }

// void simple_loop_conditional(const int N, float *x, const float *y) {
//     VECTORIZABLE_LOOP
//     for (int i = 0; i < N; i++) {
//         if (x[i] >= 10.0) {
//             x[i] += y[i];
//         }
//     }
// }

// void inner_loop_interleaved(const int N, float *__restrict x, const float *__restrict y) {
//     VECTORIZABLE_LOOP
//     for (int i = 0; i < N; ++i) {
//         x[i] = 3 * y[2 * i + 1] + y[2 * i];
//     }
// }

// void outer_loop_uniform(const int N, float *__restrict x, const float **__restrict y, const float *__restrict z) {
//     VECTORIZABLE_LOOP
//     for (int i = 0; i < N; i++) {
//         float sum = 0.0f;
//
//         VECTORIZABLE_LOOP
//         for (int j = 0; j < 6; j++) {
//             sum += y[j][i] * z[j];
//         }
//
//         x[i] = sum;
//     }
// }

//void simple_loop(const int N, float* x, const float* y, const float* z) {
//    VECTORIZABLE_LOOP
//    for (int i = 0; i < N; i++) {
//        x[i] = y[i] + z[i];
//    }
//}

// void outer_loop(const int N, const int M, const bool cond, float** a, float** b, float** c) {
//     VECTORIZABLE_LOOP
//     for (int i = 0; i < N; i++) {
//         if (cond) {
//             for (int j = 0; j < M; j++) {
//                 a[j][i] = b[j][i] + c[j][i];
//             }
//         }
//     }
// }
