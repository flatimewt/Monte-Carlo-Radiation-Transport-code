      subroutine stokes(nxp,nyp,nzp,sint,cost,sinp,cosp,phi,
     +                  hgg,g2,pi,twopi,iseed)

      implicit none

      integer iseed
      real*8 nxp,nyp,nzp,sint,cost,sinp,cosp,phi
      real*8 hgg,g2,pi,twopi

      real*8 costp,sintp,phip
      real*8 bmu,b,ri1,ri3,cosi3,sini3,cosb2,sinbt,sini2,bott,cosdph
      real*8 cosi2,sini1,cosi1

      real ran2


c***** isotropic scattering if g = 0.0 ******************************
      if(hgg.eq.0.0) then
        cost=2.*ran2(iseed)-1.
        sint=(1.-cost*cost)
        if(sint.le.0.)then
          sint=0.
        else
          sint=sqrt(sint)
        endif

        phi=twopi*ran2(iseed)
        sinp=sin(phi)
        cosp=cos(phi)

        nxp=sint*cosp
        nyp=sint*sinp
        nzp=cost

      else

c***** heyney greenstein scattering ********************************

      costp=cost
      sintp=sint
      phip=phi

      bmu=((1.+g2)-((1.-g2)/(1.-hgg+2.*hgg*ran2(iseed)))**2)/(2.*hgg)
      cosb2=bmu**2
      b=cosb2-1.

      if(abs(bmu).gt.1.) then
         if(bmu.gt.1.) then
            bmu=1.
            cosb2=1.
            b=0.
         else
            bmu=-1.
            cosb2=1.
            b=0.
         end if
      end if
      sinbt=sqrt(1.-cosb2)
      ri1=twopi*ran2(iseed)

      if(ri1.gt.pi) then
         ri3=twopi-ri1
         cosi3=cos(ri3)
         sini3=sin(ri3)

         if(bmu.eq.1.) then
            goto 100
         else
            if(bmu.eq.-1.) then
               goto 100
            end if
         end if

         cost=costp*bmu+sintp*sinbt*cosi3
         if(abs(cost).lt.1.) then
            sint=abs(sqrt(1.-cost*cost))
            sini2=sini3*sintp/sint
            bott=sint*sinbt
            cosi2=costp/bott-cost*bmu/bott
         else
            sint=0.
            sini2=0.
            if(cost.ge.1.)  cosi2=-1.
            if(cost.le.-1.) cosi2=1.
         end if

         cosdph=-cosi2*cosi3+sini2*sini3*bmu
         if(abs(cosdph).gt.1.) then
            if(cosdph.gt.1.) then
               cosdph=1.
            else
               cosdph=-1.
            end if
         end if
         phi=phip+acos(cosdph)
         if(phi.gt.twopi) phi=phi-twopi
         if(phi.lt.0.)    phi=phi+twopi

c      elseif(ri1.le.pi) then
      else  

         cosi1=cos(ri1)
         sini1=sin(ri1)

         if(bmu.eq.1.) then
            goto 100
         else
            if(bmu.eq.-1.) then
               goto 100
            end if
         end if

         cost=costp*bmu+sintp*sinbt*cosi1
         if(abs(cost).lt.1.) then
            sint=abs(sqrt(1.-cost*cost))
            sini2=sini1*sintp/sint
            bott=sint*sinbt
            cosi2=costp/bott-cost*bmu/bott
         else
            sint=0.
            sini2=0.
            if(cost.ge.1.)  cosi2=-1.
            if(cost.le.-1.) cosi2=1.
         end if

         cosdph=-cosi1*cosi2+sini1*sini2*bmu
         if(abs(cosdph).gt.1.) then
            if(cosdph.gt.1.) then
               cosdph=1.
            else
               cosdph=-1.
            end if
         end if
         phi=phip-acos(cosdph)
         if(phi.gt.twopi) phi=phi-twopi
         if(phi.lt.0.)    phi=phi+twopi

      end if

      cosp=cos(phi)
      sinp=sin(phi)
      if(cost.lt.-1.) cost=-1.
      nxp=sint*cosp
      nyp=sint*sinp
      nzp=cost

      end if

100   continue

      return
      end

