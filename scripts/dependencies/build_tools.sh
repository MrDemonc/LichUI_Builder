source "$dir_work/scripts/utils/log.sh"

# ========================================================
IMG2SDAT=true 
SAMLOADER=true  
SIGNAPK=true    
SMALI=true      

# ========================================================
if [ -d "$dir_work/tools/bin" ]; then
    log_info "tools/bin directory exists"
else
    log_info "Creating tools/bin directory"
    mkdir -p "$dir_work/tools/bin" || { log_error "Could not create tools/bin directory"; exit 1; }
fi

# ========================================================
IS_WSL() {
    if [ -e "/proc/sys/fs/binfmt_misc/WSLInterop" ] || [ -e "/run/WSL" ]; then
        echo "ON"
    else
        echo "OFF"
    fi
}

# ========================================================
folder() {
    local target="$1"
    local target_dir="$dir_work/external/$target"
    
    if [ -z "$target" ]; then
        echo "Usage: folder [folder_name]"
        echo "Available folders:"
        ls -1 "$dir_work/external"
        return 1
    fi
    
    if [ -d "$target_dir" ]; then
        cd "$target_dir"
        log_info "Navigating to: $target"
    else
        log_error "The folder '$target' does not exist in $dir_work/external"
        echo "Available folders:"
        ls -1 "$dir_work/external"
        return 1
    fi
}

# ========================================================
get_cmake_flags() {
    local flags=""
    flags+="-DCMAKE_SYSTEM_NAME=\"$(uname -s)\" "
    flags+="-DCMAKE_SYSTEM_PROCESSOR=\"$(uname -m)\" "
    flags+="-DCMAKE_BUILD_TYPE=\"Release\" "
    if type ccache &> /dev/null; then
        flags+="-DCMAKE_C_COMPILER_LAUNCHER=\"ccache\" "
        flags+="-DCMAKE_CXX_COMPILER_LAUNCHER=\"ccache\" "
    fi
    # Default compilers were moved to individual functions to allow hybrid builds
    # flags+="-DCMAKE_C_COMPILER=\"clang\" "
    # flags+="-DCMAKE_CXX_COMPILER=\"clang++\""
    echo "$flags"
}
# ========================================================
build_apktool() {
    local current_dir="$(pwd)"
    
    log_info "Building apktool..."
    
    folder "apktool" || { log_error "Could not access the apktool directory"; exit 1; }
    
    local cmds=(
        "git reset --hard"
        "git apply \"$dir_work/external/patches/apktool/0001-feat-support-aapt-optimization.patch\""
        "./gradlew build shadowJar"
        "cp -a \"scripts/linux/apktool\" \"$dir_work/tools/bin\""
        "cp -a \"brut.apktool/apktool-cli/build/libs/apktool-cli.jar\" \"$dir_work/tools/bin/apktool.jar\""
    )
    
    for cmd in "${cmds[@]}"; do
        log_info "Executing: $cmd"
        if ! eval "$cmd"; then
            log_error "Error executing: $cmd"
            exit 1
        fi
    done
    
    log_success "Apktool built successfully"
    cd "$current_dir"
}

# ========================================================
build_android_tools() {
    local current_dir="$(pwd)"
    
    log_info "Building android-tools..."
    
    folder "android-tools" || { log_error "Could not access the android-tools directory"; exit 1; }
    
    local cmds=(
        "git am --abort 2>/dev/null || true"
        "git submodule foreach --recursive \"git am --abort 2>/dev/null || true\""
        "git submodule init --quiet"
        "git submodule update --init --recursive --quiet --force"

        "rm -rf build"
        # Use GCC for android-tools due to compatibility issues with GCC 16.1.1 headers and Clang 18
        "cmake -B \"build\" $(get_cmake_flags) -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS=\"-D_Static_assert=static_assert\" -DANDROID_TOOLS_USE_BUNDLED_FMT=ON -DANDROID_TOOLS_USE_BUNDLED_LIBUSB=ON"
        # Original Clang command:
        # "cmake -B \"build\" $(get_cmake_flags) -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DANDROID_TOOLS_USE_BUNDLED_FMT=ON -DANDROID_TOOLS_USE_BUNDLED_LIBUSB=ON"
        "make -C \"build\" -j1 VERBOSE=1"
        "find \"build/vendor\" -maxdepth 1 -type f -exec test -x {} \; -exec cp -a {} \"$dir_work/tools/bin\" \;"
        "cp -a \"vendor/avb/avbtool.py\" \"$dir_work/tools/bin/avbtool\""
        "cp -a \"vendor/mkbootimg/mkbootimg.py\" \"$dir_work/tools/bin/mkbootimg\""
        "cp -a \"vendor/mkbootimg/repack_bootimg.py\" \"$dir_work/tools/bin/repack_bootimg\""
        "cp -a \"vendor/mkbootimg/unpack_bootimg.py\" \"$dir_work/tools/bin/unpack_bootimg\""
        "cp -a \"vendor/libufdt/utils/src/mkdtboimg.py\" \"$dir_work/tools/bin/mkdtboimg\""
        "mkdir -p \"$dir_work/tools/bin/gki\""
        "cp -a \"vendor/mkbootimg/gki/generate_gki_certificate.py\" \"$dir_work/tools/bin/gki/generate_gki_certificate.py\""
        "ln -sf \"$dir_work/tools/bin/mke2fs.android\" \"$dir_work/tools/bin/mke2fs\""
        "cp -a \"../ext4_utils/mkuserimg_mke2fs.py\" \"$dir_work/tools/bin/mkuserimg_mke2fs.py\""
        "ln -sf \"$dir_work/tools/bin/mkuserimg_mke2fs.py\" \"$dir_work/tools/bin/mkuserimg_mke2fs\""
        "cp -a \"../ext4_utils/mke2fs.conf\" \"$dir_work/tools/bin/mke2fs.conf\""
        "cp -a \"../f2fs_utils/mkf2fsuserimg.sh\" \"$dir_work/tools/bin/mkf2fsuserimg\""
    )
    
    for cmd in "${cmds[@]}"; do
        log_info "Executing: $cmd"
        if ! eval "$cmd"; then
            log_error "Error executing: $cmd"
            exit 1
        fi
    done
    
    log_success "Android-tools built successfully"
    cd "$current_dir"
}

# ========================================================
build_erofs_utils() {
    local current_dir="$(pwd)"
    log_info "Building erofs-utils..."
    folder "erofs-utils" || { log_error "Could not access the erofs-utils directory"; exit 1; }

    local cmds=(
        # Use Clang for erofs-utils as it requires Clang-specific flags for its vendored libcxx
        "cmake -S \"build/cmake\" -B \"out\" $(get_cmake_flags) -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DRUN_ON_WSL=\"$(IS_WSL)\" -DENABLE_FULL_LTO=\"ON\" -DMAX_BLOCK_SIZE=\"4096\""
        # Original GCC command attempt:
        # "cmake -S \"build/cmake\" -B \"out\" $(get_cmake_flags) -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DRUN_ON_WSL=\"$(IS_WSL)\" -DENABLE_FULL_LTO=\"ON\" -DMAX_BLOCK_SIZE=\"4096\""
        "make -C \"out\" -j\"$(nproc)\""
        "find \"out/erofs-tools\" -maxdepth 1 -type f -exec test -x {} \; -exec cp -a {} \"$dir_work/tools/bin\" \;"
    )

    for cmd in "${cmds[@]}"; do
        log_info "Executing: $cmd"
        if ! eval "$cmd"; then
            log_error "Error executing: $cmd"
            exit 1
        fi
    done

    log_success "erofs-utils built successfully"
    cd "$current_dir"
}

# ========================================================
build_img2sdat() {
    local current_dir="$(pwd)"
    
    if [ "$IMG2SDAT" = true ]; then
        log_info "Building img2sdat..."
        folder "img2sdat" || { log_error "Could not access the img2sdat directory"; exit 1; }
        
        local cmds=(
            "find \".\" -maxdepth 1 -type f -exec test -x {} \; -exec cp -a {} \"$dir_work/tools/bin\" \;"
        )
        
        for cmd in "${cmds[@]}"; do
            log_info "Executing: $cmd"
            if ! eval "$cmd"; then
                log_error "Error executing: $cmd"
                exit 1
            fi
        done
        
        log_success "img2sdat built successfully"
        cd "$current_dir"
    fi
}

# ========================================================
build_samloader() {
    local current_dir="$(pwd)"
    
    if [ "$SAMLOADER" = true ]; then
        log_info "Building samloader..."
        folder "samloader" || { log_error "Could not access the samloader directory"; exit 1; }
        
        local cmds=(
            "git reset --hard"
            "git apply \"$dir_work/external/patches/samloader/0001-Update-decryption-keys.patch\""
            "git apply \"$dir_work/external/patches/samloader/0002-Fix-client-request-params.patch\""
            "git apply \"$dir_work/external/patches/samloader/0003-Add-timeout-to-version.xml-request.patch\""
            "python3 -m venv \"$dir_work/tools/venv\""
            "source \"$dir_work/tools/venv/bin/activate\" && pip3 install ."
        )
        
        for cmd in "${cmds[@]}"; do
            log_info "Executing: $cmd"
            if ! eval "$cmd"; then
                log_error "Error executing: $cmd"
                exit 1
            fi
        done
        
        log_success "samloader built successfully"
        cd "$current_dir"
    fi
}

# ========================================================
build_signapk() {
    local current_dir="$(pwd)"
    
    if [ "$SIGNAPK" = true ]; then
        log_info "Building signapk..."
        folder "signapk" || { log_error "Could not access the signapk directory"; exit 1; }
        
        local cmds=(
            "./gradlew build"
            "cp -a \"scripts/linux/signapk\" \"$dir_work/tools/bin\""
            "cp -a \"signapk/build/libs/signapk-all.jar\" \"$dir_work/tools/bin/signapk.jar\""
        )
        
        for cmd in "${cmds[@]}"; do
            log_info "Executing: $cmd"
            if ! eval "$cmd"; then
                log_error "Error executing: $cmd"
                exit 1
            fi
        done
        
        log_success "signapk built successfully"
        cd "$current_dir"
    fi
}


build_android_tools

build_apktool

build_erofs_utils

build_img2sdat

build_samloader

build_signapk




