{
  runCommand,
  psp-newlib,
  psp-pthread-embedded,
  pspsdk,
}:
runCommand "psp-sysroot" { } ''
  mkdir -p $out
  cp -a ${psp-newlib}/psp $out/psp

  chmod -R +w $out/psp
  cp -af ${psp-pthread-embedded}/psp/include/pthread.h $out/psp/include/pthread.h
  cp -af ${psp-pthread-embedded}/psp/include/sched.h $out/psp/include/sched.h
  cp -af ${psp-pthread-embedded}/psp/include/semaphore.h $out/psp/include/semaphore.h
  cp -af ${psp-pthread-embedded}/psp/include/pte_types.h $out/psp/include/pte_types.h
  cp -af ${psp-pthread-embedded}/psp/include/bits/posix_opt.h $out/psp/include/bits/posix_opt.h
  cp -af ${psp-pthread-embedded}/psp/include/sys/_pthreadtypes.h $out/psp/include/sys/_pthreadtypes.h
  cp -af ${psp-pthread-embedded}/psp/include/sys/sched.h $out/psp/include/sys/sched.h
  cp -af ${psp-pthread-embedded}/psp/include/sys/pte_generic_osal.h $out/psp/include/sys/pte_generic_osal.h
  cp -af ${psp-pthread-embedded}/psp/lib/libpthread.a $out/psp/lib/libpthread.a

  if [ -d ${pspsdk}/psp/sdk/include ]; then
    cp -af ${pspsdk}/psp/sdk/include/. $out/psp/include/
  fi

  if [ -d ${pspsdk}/psp/lib ]; then
    cp -af ${pspsdk}/psp/lib/. $out/psp/lib/
    chmod -R u+w $out/psp/lib
  fi

  if [ -d ${pspsdk}/psp/sdk/lib ]; then
    chmod -R u+w $out/psp/lib
    cp -af ${pspsdk}/psp/sdk/lib/. $out/psp/lib/
  fi

  chmod -R -w $out/psp
''
