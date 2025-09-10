#include <substrate.h>

void (*orig_UpdateBigBoostState)(void* self);
void hook_UpdateBigBoostState(void* self) {
    // Hook code vô hạn
    orig_UpdateBigBoostState(self);

    // Set nitro lớn vô hạn
    void* mState = get_mState(self);
    setBigBoostFull(mState); // Bạn phải implement get/set theo IL2CPP
}

// Tương tự
void (*orig_UpdateSmallBoostState)(void* self);
void hook_UpdateSmallBoostState(void* self) {
    orig_UpdateSmallBoostState(self);
    void* mState = get_mState(self);
    setSmallBoostFull(mState);
}

void (*orig_UpdateAccelState)(void* self);
void hook_UpdateAccelState(void* self) {
    orig_UpdateAccelState(self);
    void* mState = get_mState(self);
    setAccelFull(mState);
}

__attribute__((constructor))
static void init() {
    //public class VehicleMechaFlyingSkillEventCtrl
    MSHookFunction((void*)0x62AA738, (void*)hook_UpdateBigBoostState, (void**)&orig_UpdateBigBoostState); // private void UpdateBigBoostState() { }
    MSHookFunction((void*)0x62AA880, (void*)hook_UpdateSmallBoostState, (void**)&orig_UpdateSmallBoostState); // private void UpdateSmallBoostState() { }
    MSHookFunction((void*)0x62AA53C, (void*)hook_UpdateAccelState, (void**)&orig_UpdateAccelState); // private void UpdateAccelState(ref IPropsHitMgr hitMgr) { }
}
