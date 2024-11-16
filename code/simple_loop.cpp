#define ENABLE_VECTORIZATION 1

#if ENABLE_VECTORIZATION
    #define VECTORIZABLE_LOOP \
    _Pragma("clang loop vectorize(enable) interleave(enable) vectorize_predicate(enable)")
#else
    #define VECTORIZABLE_LOOP \
    _Pragma("clang loop vectorize(disable) interleave(disable)")
#endif

void simple_loop_restrict(const int N, float *__restrict x, const float *__restrict y, const float *__restrict z) {
    VECTORIZABLE_LOOP
    for (int i = 0; i < N; i++) {
        x[i] = y[i] + z[i];
    }
}

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